import pandas as pd
from pathlib import Path
from Bio import Entrez, SeqIO
from urllib.error import HTTPError, URLError
from io import StringIO
import time
"""
Entrez.email = "pia.sotli@gmail.com"  
Entrez.api_key = "a5b4487a22d64bedc996512e7b495df47608" #v config?
"""

"""
v config.yaml 
ncbi_api_key: "tvoj_api_key"
"""
Entrez.api_key = snakemake.config["ncbi_api_key"]
Entrez.email = snakemake.config["ncbi_email"]

def fetch_protein_record(accession: str, retries: int = 3, base_delay: float = 0.5):
    accession = str(accession).strip()
    if not accession:
        return None

    for attempt in range(retries):
        try:
            handle = Entrez.efetch(
                db="protein",
                id=accession,
                rettype="gp",  
                retmode="text"
            )
            try:
                text = handle.read()
            finally:
                handle.close()

            if not text.strip():
                return None

            record = SeqIO.read(StringIO(text), "genbank")
            return record

        except (HTTPError, URLError, RuntimeError):
            if attempt == retries - 1:
                raise
            time.sleep(base_delay * (2 ** attempt))
        except Exception:
            return None

def protein_info_from_record(accession: str):
    record = fetch_protein_record(accession)
    if record is None:
        return None
    title = record.description
    keywords = ["movement protein", "movement-protein", "mvp"] #ali so še kakšna poimenovanja za movement protein 
    poly = "polyprotein" #ali je mogoče tudi pri hypothetical in uncharacterized proteinih treba tako
    texts = []
    if record.description:
        texts.append(record.description)
    comment = record.annotations.get("comment")
    if comment:
        texts.append(comment)
    for feat in record.features:
        for values in feat.qualifiers.values():
            for v in values:
                texts.append(v)
    
    full_text = " ".join(texts).lower()
    found_mvp = any(k in full_text for k in keywords)
    found_poly = poly in full_text

    return title, found_mvp, found_poly

def get_taxonomy(taxonomy_list):

    kingdom = None
    phylum = None
    class_ = None
    order = None
    family = None
    genus = None
    species = None

    for tax in taxonomy_list:
        if tax.startswith("k_"):
            kingdom = tax[2:]
        elif tax.startswith("p_"):
            phylum = tax[2:]
        elif tax.startswith("c_"):
            class_ = tax[2:]
        elif tax.startswith("o_"):
            order = tax[2:]
        elif tax.startswith("f_"):
            family = tax[2:]
        elif tax.startswith("g_"):
            genus = tax[2:]
        elif tax.startswith("s_"):
            species = tax[2:]

    return kingdom, phylum, class_, order, family, genus, species


contigs = []
for rep_file, coverm_file, orf_file, mmseqs_file in zip(
    snakemake.input.reps,
    snakemake.input.coverm,
    snakemake.input.longest_orfs,
    snakemake.input.mmseqs2_proteins
):
    df_rep = pd.read_csv(rep_file, sep="\t", header=None)
    df_coverm = pd.read_csv(coverm_file, sep="\t", header=0)
    df_orfs = pd.read_csv(orf_file, sep="\t", header=0)
    df_proteins = pd.read_csv(mmseqs_file, sep="\t", header=None)

    #rename columns in proteins file
    df_proteins.columns = [
    "ORF_ID",
    "target",
    "evalue",
    "pident",
    "qlen",
    "tlen",
    "alnlen",
    "bits",
    "protein_taxonomy"
    ]

    #proteins file - filter for only top ORFs (longest)
    #take only the best hit for each ORF (lowest evalue)
    longest_orfs = set(df_orfs["ORF_ID"])

    df_proteins["evalue"] = pd.to_numeric(df_proteins["evalue"], errors="coerce")
    df_proteins = df_proteins.dropna(subset=["evalue"])

    df_proteins = (
        df_proteins
        .sort_values(["ORF_ID", "evalue"])
        .drop_duplicates("ORF_ID", keep="first")
    )

    df_proteins = df_proteins[df_proteins["ORF_ID"].isin(longest_orfs)].copy()

    #rename columns in representative file
    df_rep.columns = [
        "Contig",
        "taxid",
        "rank",
        "name",
        "col4",
        "col5",
        "col6",
        "col7",
        "taxonomy"
    ]

    #merging the dataframes
    df_rep["Contig"] = df_rep["Contig"].astype(str).str.strip()
    df_coverm["Contig"] = df_coverm["Contig"].astype(str).str.strip()
    df_orfs["Contig"] = (df_orfs["ORF_ID"].astype(str).str.replace(r"_ORF\.\d+$", "", regex=True).str.strip())
    df_proteins["Contig"] = df_proteins["ORF_ID"].str.replace(r"_ORF\.\d+$", "", regex=True).str.strip()

    merged = df_rep.merge(df_coverm, on="Contig", how="left")
    merged = merged.merge(df_orfs, on="Contig", how="left")
    merged = merged.merge(df_proteins, on="Contig", how="left")
    
    #create the table
    sample_name = rep_file.split("/")[-2]
    for idx, row in merged.iterrows():
        node = row["Contig"].split("_")[1]
        name = f"{sample_name}_NODE_{node}"
        length = row["Contig"].split("_")[3]
        cov = row["Contig"].split("_")[5]
        taxonomy_list = str(row["taxonomy"]).split(";")
        kingdom, phylum, class_, order, family, genus, species = get_taxonomy(taxonomy_list)
        rpkm = row[f"{sample_name}_aln_sorted RPKM"]
        read_count = row[f"{sample_name}_aln_sorted Read Count"]
        orf_length = row["orf_len"]
        orf_coverage = row["orf_perc"]

        accession = row["target"]
        if pd.isna(accession):
            title, found_mvp, found_poly = None, False, False
        else:
            protein_info = protein_info_from_record(accession)
            if protein_info is None:
                title, found_mvp, found_poly = None, False, False
            else:
                title, found_mvp, found_poly = protein_info
        evalue = row["evalue"]
        pident = row["pident"]
        qlen = row["qlen"]
        tlen = row["tlen"]
        alnlen = row["alnlen"]
        bits = row["bits"]
        protein_taxonomy_list = str(row["protein_taxonomy"]).split(";")
        p_kingdom, p_phylum, p_class, p_order, p_family, p_genus, p_species = get_taxonomy(protein_taxonomy_list)


        contig = {
            "CONTIG NAME": name,
            "LENGTH": length,
            "SPADES_COV": cov,
            "KINGDOM": kingdom,
            "PHYLUM": phylum,
            "CLASS": class_,
            "ORDER": order,
            "FAMILY": family,
            "GENUS": genus,
            "SPECIES": species,
            "COVERM RPKM": rpkm,
            "COVERM READ COUNT": read_count,
            "LONGEST ORF LENGTH": orf_length,
            "LONGEST ORF COVERAGE": orf_coverage,
            "PROTEIN ACCESSION": accession,
            "PROTEIN TITLE": title,
            "MVP": found_mvp,
            "POLYPROTEIN": found_poly,
            "EVALUE": evalue,
            "PIDENT": pident,
            "QUERY(ORF) LEN": qlen,
            "TARGET PROTEIN LEN": tlen,
            "ALIGNMENT LEN": alnlen,
            "BITS": bits,
            "PROTEIN KINGDOM": p_kingdom,
            "PROTEIN PHYLUM": p_phylum,
            "PROTEIN CLASS": p_class,
            "PROTEIN ORDER": p_order,
            "PROTEIN FAMILY": p_family,
            "PROTEIN GENUS": p_genus,
            "PROTEIN SPECIES": p_species
        }
        contigs.append(contig)

df_final = pd.DataFrame(contigs)
df_final.to_csv(snakemake.output.table, sep="\t", index=False)




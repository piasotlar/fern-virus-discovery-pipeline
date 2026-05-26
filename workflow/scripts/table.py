import pandas as pd
from pathlib import Path
from Bio import Entrez, SeqIO
from urllib.error import HTTPError, URLError
from io import StringIO
import time
import re
from pandas.errors import EmptyDataError

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

    mvp_patterns = [
        r"\bmovement protein\b",
        r"\bmovement-protein\b",
        r"\bcell-to-cell movement protein\b",
        r"\bviral movement protein\b",
        r"\b30k movement protein\b",
        r"\b30 kda movement protein\b",
        r"\btriple gene block protein 1\b",
        r"\btriple gene block protein 2\b",
        r"\btriple gene block protein 3\b",
        r"\btgb1\b",
        r"\btgb2\b",
        r"\btgb3\b",
        r"\bmp\b",
        r"\bmvp\b"
    ]

    cp_patterns = [
        r"\bcoat protein\b",
        r"\bcoat-protein\b",
        r"\bcapsid protein\b",
        r"\bcp\b"
    ]

    poly_patterns = [
        r"\bpolyprotein\b"
    ]

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

    found_mvp = any(
        re.search(pattern, full_text)
        for pattern in mvp_patterns
    )

    found_cp = any(
        re.search(pattern, full_text)
        for pattern in cp_patterns
    )

    found_poly = any(
        re.search(pattern, full_text)
        for pattern in poly_patterns
    )

    return found_mvp, found_poly, found_cp

def get_taxonomy(taxonomy_list):

    realm = None
    kingdom = None
    phylum = None
    class_ = None
    order = None
    family = None
    genus = None
    species = None

    for tax in taxonomy_list:
        tax = tax.strip()
        if tax.endswith("viria") and not tax.startswith(("k_", "p_", "c_", "o_", "f_", "g_", "s_")):
            realm = tax.replace("-_", "")
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

    return realm,kingdom, phylum, class_, order, family, genus, species

def clean_hmmer_target(target):

    target = str(target)
    target = target.replace("sequence_", "")
    target = target.replace(".aln", "")

    return target

def query_to_contig(query_name):
    m = re.match(r"(NODE_\d+)_", str(query_name))
    if m:
        return m.group(1)
    return None

def query_to_orf(query_name):
    m = re.search(r"(ORF\.\d+)", str(query_name))
    if m:
        return m.group(1)
    return None

def parse_hmmer_tblout(hmmer_file):

    rows = []
    with open(hmmer_file) as f:
        for line in f:
            if line.startswith("#") or not line.strip():
                continue

            parts = line.strip().split()
            target_name = parts[0]
            full_query_name = parts[2]
            contig = query_to_contig(full_query_name)
            query_name = query_to_orf(full_query_name)
            evalue = float(parts[7])
            score = float(parts[8])

            rows.append({

                "CONTIG NAME": contig,
                "HMMER_MP_TARGET": clean_hmmer_target(target_name),
                "HMMER_MP_EVALUE": evalue,
                "HMMER_MP_SCORE": score,
                "HMMER_MP_QUERY": query_name

            })

    if not rows:

        return pd.DataFrame(columns=[
            "CONTIG NAME",
            "HMMER_MP_HIT",
            "HMMER_MP_TARGET",
            "HMMER_MP_EVALUE",
            "HMMER_MP_SCORE",
            "HMMER_MP_QUERY"
        ])

    df = pd.DataFrame(rows)

    # za vsak contig vzemi najboljši HMMER zadetek z najmanjšim E-value

    df = df.sort_values(["CONTIG NAME", "HMMER_MP_EVALUE", "HMMER_MP_SCORE"],ascending=[True, True, False])
    df_best = df.groupby("CONTIG NAME", as_index=False).first()
    df_best["HMMER_MP_HIT"] = "Yes"
    return df_best

table_orfs = snakemake.input.table_orfs
df_table_orfs = pd.read_csv(table_orfs, sep="\t", header=0)
contigs = []
for rep_file, coverm_file, orf_file, hmmer_file in zip(
    snakemake.input.reps,
    snakemake.input.coverm,
    snakemake.input.longest_orfs,
    snakemake.input.hmmer
):
    
    sample_name = rep_file.split("/")[-2]

    try:
        df_rep = pd.read_csv(rep_file, sep="\t", header=None)
    except EmptyDataError:
        continue

    if df_rep.empty:
        continue

    try:
        df_coverm = pd.read_csv(coverm_file, sep="\t", header=0)
    except EmptyDataError:
        df_coverm = pd.DataFrame(columns=[
            "Contig",
            f"{sample_name}_aln_sorted Mean",
            f"{sample_name}_aln_sorted RPKM",
            f"{sample_name}_aln_sorted Read Count"
        ])

    try:
        df_orfs = pd.read_csv(orf_file, sep="\t", header=0)
    except EmptyDataError:
        df_orfs = pd.DataFrame(columns=[
            "ORF_ID", "contig_len", "orf_len", "orf_perc"
        ]) 
    df_hmmer = parse_hmmer_tblout(hmmer_file)
    
    df_table_sample = df_table_orfs[df_table_orfs["sample"] == sample_name].copy()

    df_table_sample["evalue"] = pd.to_numeric(df_table_sample["evalue"], errors="coerce")

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

    merged = df_rep.merge(df_coverm, on="Contig", how="left")
    merged = merged.merge(df_orfs, on="Contig", how="left")
    
    #create the table
    sample_name = rep_file.split("/")[-2]
    for idx, row in merged.iterrows():
        node = row["Contig"].split("_")[1]
        name = f"NODE_{node}"
        length = row["Contig"].split("_")[3]
        cov = row["Contig"].split("_")[5]
        taxonomy_list = str(row["taxonomy"]).split(";")
        realm, kingdom, phylum, class_, order, family, genus, species = get_taxonomy(taxonomy_list)
        rpkm = float(row[f"{sample_name}_aln_sorted RPKM"])
        read_count = int(row[f"{sample_name}_aln_sorted Read Count"])
        orf_length = int(row["orf_len"])
        orf_coverage = float(row["orf_perc"])

        accessions = (
            df_table_sample.loc[df_table_sample["contig"] == f"NODE_{node}", "target"]
            .dropna()
            .astype(str)
            .str.strip()
            .unique()
        )
        num_of_orfs = df_table_sample[df_table_sample["contig"] == f"NODE_{node}"].shape[0]

        found_mvp = False
        found_poly = False
        found_cp = False
        
        for accession in accessions:
            protein_info = protein_info_from_record(accession)

            if protein_info is None:
                continue

            mvp, poly, cp = protein_info

            found_mvp = found_mvp or mvp
            found_poly = found_poly or poly
            found_cp = found_cp or cp

            if found_mvp and found_poly and found_cp:
                break

        hmmer_row = df_hmmer[df_hmmer["CONTIG NAME"] == name]

        if not hmmer_row.empty:
            hmmer_hit = hmmer_row.iloc[0]["HMMER_MP_HIT"]
            hmmer_target = hmmer_row.iloc[0]["HMMER_MP_TARGET"]
            hmmer_evalue = hmmer_row.iloc[0]["HMMER_MP_EVALUE"]
            hmmer_score = hmmer_row.iloc[0]["HMMER_MP_SCORE"]
            hmmer_query = hmmer_row.iloc[0]["HMMER_MP_QUERY"]
        else:
            hmmer_hit = "No"
            hmmer_target = ""
            hmmer_evalue = ""
            hmmer_score = ""
            hmmer_query = ""

        contig = {
            "SAMPLE": sample_name,
            "CONTIG NAME": name,
            "LENGTH": length,
            "SPADES_COV": cov,
            "REALM": realm,
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
            "NUM OF ORFS": num_of_orfs,
            "MVP": found_mvp,
            "CP": found_cp,
            "POLYPROTEIN": found_poly,
            "HMMER_MP_HIT": hmmer_hit,
            "HMMER_MP_TARGET": hmmer_target,
            "HMMER_MP_EVALUE": hmmer_evalue,
            "HMMER_MP_SCORE": hmmer_score,
            "HMMER_MP_QUERY": hmmer_query
        }
        contigs.append(contig)

df_final = pd.DataFrame(contigs)
df_final.to_csv(snakemake.output.table, sep="\t", index=False)
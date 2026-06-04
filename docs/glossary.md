# Medical Glossary

**Note on Longitudinal Data:** Variables ending in a suffix `_#` (e.g., `_0`, `_1`) represent measurements taken at specific time points:

-   `_0`: Baseline (Pre-treatment)
-   `_1` through `_12`: Chemotherapy Cycles 1-12

| Variable | Description (Units) | Type | Values / Key |
|----------------|----------------|----------------|------------------------|
| **Identifiers** |  |  |  |
| record_id | Record ID | Numeric | N/A |
| pgh_number | PGH Number | Numeric | N/A |
| **Demographics** |  |  |  |
| age | Age (years) | Numeric | **Valid:** 18 - 120 |
| sex | Sex | Factor | 1 = Male<br />2 = Female |
| residence | Residence density | Factor | 1 = Urban<br />2 = Rural<br />3 = Semi-urban |
| **Clinical** |  |  |  |
| hiv_status | HIV diagnosis status | Factor | 1 = Negative<br />2 = Positive |
| cancer_site | Location of cancer | Factor | 1 = Esophagus<br />2 = Gastric<br />3 = Gastro-esophageal junction<br />4 = Gall bladder, Biliary, and Pancreas<br />9 = Colorectal<br />11 = Anal |
| histology | Histology type | Factor | 1 = Adenocarcinoma/carcinoma<br />2 = Squamous carcinoma<br   />3 = Sarcoma<br />4 = Carcinoid<br />5 = Lymphoma<br   />7 = Other |
| cancer_stage | Cancer stage at diagnosis | Factor | 1 = Stage I<br />2 = Stage 2<br />3 = Stage 3<br />4 = Stage IV or Unknown/Undocumented |
| tx_concurrent_rtx | Concurrent radiotherapy administered | Factor | 1 = Yes<br />2 = No |
| tx_intent | Chemotherapy treatment intent | Factor | 1 = Curative<br />2 = Palliative |
| chemo_seq | Sequence of chemotherapy | Factor | 1 = Neoadjuvant<br />2 = Adjuvant<br />3 = Definitive |
| chemo_type | Chemotherapy regimen prescribed | Factor | 1 = Platinum/Paclitaxel<br />2 = Platinum/5-FU<br />3 = LCV/5-FU<br />4 = CapeOx<br />5 = FOLFOX4<br />6 = Capecitabine<br />20 = Irinotecan<br />21 = Other |
| cycles_prescribed | Planned chemotherapy cycles | Numeric | **Valid:** 1 - 12 |
| cycles_given | Administered chemotherapy cycles | Numeric | **Valid:** 1 - 12 |
| completion_rate | Treatment completion rate (%) | Numeric | **Valid:** 0 - 100% |
| **Medical History** |  |  |  |
| comorbid_htn | Comorbid hypertension | Factor | 1 = Yes<br />2 = No |
| comorbid_dm | Comorbid diabetes mellitus | Factor | 1 = Yes<br />2 = No |
| comorbid_tb | Comorbid tuberculosis | Factor | 1 = Yes<br />2 = No |
| comorbid_asthma | Comorbid asthma | Factor | 1 = Yes<br />2 = No |
| comorbid_chd | Comorbid cardiac disease | Factor | 1 = Yes<br />2 = No |
| comorbid_copd | Comorbid COPD | Factor | 1 = Yes<br />2 = No |
| comorbid_ckd | Comorbid kidney disease | Factor | 1 = Yes<br />2 = No |
| comorbid_epilepsy | Comorbid epilepsy | Factor | 1 = Yes<br />2 = No |
| comorbid_none | No comorbidities noted | Factor | 1 = Yes<br />2 = No |
| hx_etoh | History of alcohol use | Factor | 1 = Yes<br />2 = No |
| hx_tobacco | History of tobacco use | Factor | 1 = Yes<br />2 = No |
| hx_cancer | Family history of cancer | Factor | 1 = Yes<br />2 = No |
| death_date | Date of death (if death occurred) | Date | **Valid:** 2012-01-01 through 2021-12-31 |
| **Baseline-Only Measurements** |  |  |  |
| weight_0 | Weight (kg) | Numeric | **Valid:** |
| height_0 | Height (cm) | Numeric | **Valid:** |
| bmi_0 | Body Mass Index | Numeric | **Ref:** 18.5 - 24.9 <sup>\[1\]</sup> |
| cd4_count_0 | CD4+ T-cell count | Numeric | **Ref:** |
| urea_0 | Serum urea | Numeric | **Ref:** |
| creat_0 | Serum creatinine | Numeric | **Ref:** |
| cr_clear_0 | Creatinine clearance | Numeric | **Ref:** |
| albi_score_0 | Albumin-Bilirubin score | Numeric | **Ref:** |
| cea_0 | Carcinoembryonic Antigen | Numeric | **Ref:** |
| ca199_0 | Cancer Antigen 19-9 | Numeric | **Ref:** |
| **Longitudinal - Hematology** |  |  |  |
| hb\_# | Hemoglobin level | Numeric | **Ref:** \> 12 |
| mcv\_# | Mean Corpuscular Volume | Numeric | **Ref:** |
| mch\_# | Mean Corpuscular Hemoglobin | Numeric | **Ref:** |
| plt\_# | Platelet Count | Numeric | **Ref:** \> 150 |
| wbc\_# | White Blood Cell count ($10^9/L$) | Numeric | **Ref:** \> 4 |
| anc\_# | Absolute Neutrophil Count ($10^9   cells/L$) | Numeric | **Ref:** \> 2 |
| lcc\_# | Lymphocyte Cell Count | Numeric | **Ref:** \> 1 |
| **Longitudinal - Chemistry** |  |  |  |
| sodium\_# | Serum Sodium | Numeric | **Ref:** \> 133 |
| potassium\_# | Potassium | Numeric | **Ref:** 3.5 - 5.2 |
| **Longitudinal - Liver Function** |  |  |  |
| tp\_# | Total Protein | Numeric | **Ref:** |
| alb\_# | Serum Albumin (g/L) | Numeric | **Ref:** 35 - 55 |
| tbil\_# | Total Bilirubin | Numeric | **Ref:** 3.0 - 20.0 |
| dbil\_# | Direct bilirubin | Numeric | **Ref:** |
| alp\_# | Alkaline phosphatase | Numeric | **Ref:** 20.0 - 130.0 |
| alt\_# | Alanine transaminase | Numeric | **Ref:** 0 - 45 |
| ast\_# | Aspartate Aminotransferase | Numeric | **Ref:** 0 - 50 |
| ggt\_# | Gamma-glutamyl Transferase | Numeric | **Ref:** |
| **Longitudinal - Management** |  |  |  |
| cycle_delayed\_# | Cycle delayed due to toxicity | Factor | 1 = Yes<br />2 = No |
| hosp_toxicity\_# | Hospitalization occurred due to toxicity | Factor | 1 = Yes<br />2 = No |
| hosp_days\_# | Duration of hospitalization (Days) | Numeric | **Valid:** |
| transfusion_given\_# | Blood transfusion administered | Factor | 1 = Yes<br />2 = No |
| transfusion_units\_# | Units of blood transfused | Numeric | **Valid:** |
| csfg_indicated\_# | CSF-G Indication | Factor | 1 = Yes<br />2 = No |

**Reference Standards:** Unless otherwise noted, all laboratory reference ranges ('Ref') and toxicity grades are derived from the document `Normal ranges and Adverse Events grading system.xlsx`.

\[1\] Abarca-Gómez, Leandra, Ziad A Abdeen, Zargar Abdul Hamid, Niveen M Abu-Rmeileh, Benjamin Acosta-Cazares, Cecilia Acuin, Robert J Adams, et al. 2017. “Worldwide Trends in Body-Mass Index, Underweight, Overweight, and Obesity from 1975 to 2016: A Pooled Analysis of 2416 Population-Based Measurement Studies in 128(\cdot)9 Million Children, Adolescents, and Adults.” The Lancet 390 (10113): 2627–42. https://doi.org/10.1016/S0140-6736(17)32129-3.

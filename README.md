# Pokémon Data Analysis: Traditional vs. Modern ML Approaches
 
**BANA 8083 Capstone Project — Grey Myers**
 
A full data science workflow comparing traditional statistical tools against Google Vertex AI AutoML for binary classification. The project uses the complete Pokémon Pokédex as the dataset, predicting whether a Pokémon is Legendary based on its base stats.
 
---
 
## Project Overview
 
This project was motivated by the idea that data analysis is more engaging when the topic resonates. Pokémon offers a rich, structured dataset that provides a legitimate platform to compare approaches any real-world analyst would encounter — from manual web scraping and exploratory analysis to cloud-based AutoML.
 
**Research Question:** Can a Pokémon's base stats (HP, Attack, Defense, Sp_Atk, Sp_Def, Speed) predict whether it is Legendary?
 
**The Core Argument:** Better accuracy does not always mean a better solution. Time, cost, and interpretability all matter.
 
---
 
## Tools Used
 
| Tool | Purpose |
|------|---------|
| Python (requests, certifi, pandas) | Web scraping and data collection |
| R Studio (tidyverse, ggplot2, patchwork) | Exploratory data analysis |
| Orange Data Mining | Decision tree classification |
| Google Vertex AI AutoML | Cloud-based classification |
 
---
 
## Repository Structure
 
```
pokemon-capstone/
│
├── README.md
├── data/
│   ├── pokemon_raw_scraped.csv         # Raw data scraped from pokemondb.net
│   ├── pokemon_engineered_features.csv # Engineered columns created for this project
│   └── pokemon_capstone_complete.csv   # Full dataset used for modeling
│
├── python/
│   └── Capstone_Pokemon_Dataset_Scraping_Code.ipynb
│
└── r/
    └── Capstone_Pokemon_EDA.R
```
 
---
 
## Data Collection
 
Since pokemondb.net does not provide a public API, Python was used to fetch the complete Pokédex HTML table directly and parse it into a structured CSV.
 
**Libraries:** `requests`, `certifi`, `pandas`  
**Source:** [pokemondb.net/pokedex/all](https://pokemondb.net/pokedex/all)  
**Result:** 1,219 observations across all 9 generations
 
The raw scrape was then cleaned and extended with the following engineered columns:
 
| Column | Description |
|--------|-------------|
| `Name` | Reformatted for consistency — e.g. `Charizard (Mega X)` instead of `Mega Charizard X` |
| `Base_Name` | The base Pokémon name independent of form — e.g. `Charizard` for all Charizard variants |
| `Form` | Extracted form variant — e.g. `Mega X`, `Alolan`, `Galarian` |
| `Generation` | Mapped from Dex number ranges (Gen 1: #1–151 through Gen 9: #906–1025) |
| `Legendary` | Binary — manually researched and added |
| `Mythical` | Binary — manually researched and added |
| `Shiny_Obtainable` | Binary — manually researched and added |
 
---
 
## Exploratory Data Analysis
 
EDA was conducted in R Studio using `tidyverse` and `ggplot2`. Key findings:
 
- **Class imbalance:** 1,114 Non-Legendary vs 105 Legendary — 91% of the dataset is non-legendary
- **Legendary Pokémon consistently rank higher** across all six base stats
- **Speed** ranges from 5 to 200 — extreme outliers are almost exclusively legendaries
- **Sp_Def and Speed** show the strongest correlation with Legendary status
- **Attack** is the weakest predictor — many non-legendaries have high attack
- `Total` was excluded from modeling — it is a perfect linear sum of the 6 stats and would cause data leakage
 
The EDA produces four visualizations:
1. Speed distribution histogram
2. HP spread by Legendary class (box plot)
3. All 6 stats compared across Legendary vs Non-Legendary (faceted box plots)
4. Attack vs Sp_Atk scatter plot by class
 
---
 
## Modeling
 
### Feature Set
All models used the same 6 features: `HP`, `Attack`, `Defense`, `Sp_Atk`, `Sp_Def`, `Speed`
 
Excluded: `Total` (leakage), `Mythical` (target-adjacent leakage), `Type_1/Type_2` (redundant with stats, caused Orange binarization error), all identifier columns
 
### Orange Decision Tree
- 5-fold stratified cross validation
- Default settings — grew to depth 12, 71 nodes (signs of overfitting)
- Free, runs locally, results in seconds
 
### Google Vertex AI AutoML
- AutoML classification, confidence threshold 0.5
- Low cost compute node
- Data processing: ~8 minutes
- Model training: ~1.5 hours
- Incurred cloud billing charges
 
---
 
## Results
 
| Metric | Orange Decision Tree | Google Vertex AI | Winner |
|--------|---------------------|-----------------|--------|
| AUC | 0.694 | 0.973 | Vertex AI |
| Accuracy | 92.5% | 91.2% | Tie |
| F1 Score | 0.922 | 0.912 | Tie |
| Legendary Recall | 47.6% | ~15% | Orange |
| Training Time | Seconds | ~1.5 hours | Orange |
| Cost | Free | Cloud billing | Orange |
| Interpretability | High | Low (black box) | Orange |
 
**Vertex AI's AUC of 0.973 vs Orange's 0.694 is a dramatic improvement** — but both models struggled with legendary recall due to class imbalance. Neither tool solved the core problem without additional techniques like SMOTE or threshold tuning.
 
### Feature Importance (Vertex AI Shapley Values)
1. Sp_Def — strongest predictor
2. Speed
3. HP
4. Sp_Atk
5. Defense
6. Attack — weakest predictor
 
---
 
## Key Conclusion
 
> The right tool depends on scale and budget. For a dataset of 1,219 rows, a 0.279 AUC improvement is hard to justify against 1.5 hours of training time and cloud billing costs when a free tool runs in seconds. At enterprise scale with millions of rows, Vertex AI's advantages become clear. Every tool has a place — Python for collection, R for EDA, Orange for interpretable modeling, Vertex AI for scale.
 
---
 
## Limitations
 
- Class imbalance (91% non-legendary) affected both models — neither achieved strong legendary recall without threshold tuning
- Orange's tree depth of 12 / 71 nodes suggests overfitting — pruning to depth 4–5 would likely improve generalization
- Vertex AI is a black box — feature importance is visible but decision rules are not
- Type columns were excluded due to Orange's 16-category binarization limit — adding them to Vertex showed no meaningful accuracy improvement
 
---
 
## Data Sources
 
- Base stat data scraped from [pokemondb.net/pokedex/all](https://pokemondb.net/pokedex/all)
- Engineered columns (Name formatting, Base_Name, Form, Generation, Legendary, Mythical, Shiny_Obtainable) created by Grey Myers
 
---
 
## License
 
Code: MIT License  
Dataset (engineered columns): CC BY-SA 4.0 — credit required, derivative work acknowledged

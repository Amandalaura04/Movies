# Business Statistics — SQ2

Current SQ2 (reworded on 2 November 2026): “How is awareness of feed personalisation related to perceived control, and does this relationship differ across age groups?”

- `Business_Statistics_SQ2.ipynb` is Amanda Luijendijk's current analysis, aligned with the SQ2 section in the shared group notebook.
- [Shared group notebook](https://colab.research.google.com/drive/1qGZsNhBEB7gmZtuy59oYEtWoXefIS7x5) contains the group's existing work plus the updated SQ2 section.
- `Business_Statistics_SEM.ipynb` is the earlier exploratory analysis. It does not answer the current awareness question and is not the primary SQ2 result.

## Run

Install `requirements.txt`. Place your authorised `Responses.xlsx` beside the notebook, or set `BS_DATA_PATH` to its location. The loader also checks the earlier Downloads filename and the shared Colab Notebooks folder in mounted Google Drive. Run all cells from top to bottom.

No raw survey data or respondent-level outputs are included in GitHub. Public notebooks have saved outputs cleared. The shared notebook retains aggregate SQ2 results.

## Measurement and results

The survey does not directly measure the amount of personalisation. SQ2 directly studies awareness of personal-data-based feed shaping, with a single perceived-control item as the outcome. The question is worded around awareness to match this measure. The notebook states this mismatch explicitly. Causal effects of personalisation cannot be estimated from these data.

The analysis uses age categories, an age-adjusted OLS model with HC3 standard errors, an ordinal Spearman sensitivity check, and an exploratory interaction model. OLS treats the five response categories as equally spaced. No age groups are merged after inspecting results.

Validated on 1 November 2026 against the shared Responses.xlsx: 685 rows, 57 columns; 673 complete SQ2 responses. Both the full 99-cell group notebook and the focused 23-cell SQ2 notebook executed without cell errors.

The awareness coefficient is -0.027 (95% HC3 CI -0.116 to 0.061; p=0.543). The exploratory interaction has p=0.0000725, but sparse age groups limit interpretation. These are different hypotheses; a nonsignificant overall coefficient does not rule out variation by age. The notebook generates its conclusion from the executed results.

The provisional three-question Bonferroni correction is labelled as provisional. Agree the final family of confirmatory tests with the group. SQ1 and SQ3 are not completed or validated as final analyses by this update.

Prepared with Codex assistance. Review the measurement choices, recruitment assumptions, code and conclusions, and explain your own contribution before submission.

Amanda Luijendijk’s section includes simple English explanations and supporting rank/scaling work, the earlier age-group comparison, and the model including social media use. Earlier SEM work remains separate and is not used as evidence for the updated question.



## Three-category chi-square check before SEM

Added on 2 November 2026: awareness and control are grouped as Disagree (1–2), Neutral (3), and Agree (4–5), for this exploratory independence test only. The regression and SEM retain five-point scores. N=674, Pearson chi-square(4)=8.596, p=0.0720292; Cramér’s V=0.080. All nine expected counts exceed 5 (minimum 12.26). We do not reject independence at 0.05. The test does not account for age and differs from SEM model-fit chi-square.

The updated focused SQ2 notebook (25 cells) and SEM notebook (16 cells) both executed without cell errors. This does not certify the current full group notebook: an existing earlier group cell references an undefined relationship_df.


## Updated exploratory SEM — 2 November 2026

Two types of structural paths are included: awareness → latent Control and age-group indicators → latent Control. This is an additive model; the separate regression interaction test addresses moderation. The three candidate control indicators remain unchanged. The model uses 669 complete responses, converges, and has no negative variances. Awareness estimate=0.090 (robust normal-approximation 95% CI 0.026–0.154; unadjusted p=0.00569027). Alpha=0.481, so measurement remains weak. These exploratory latent-factor results are not directly comparable with single-item regression coefficients. Course acceptance of the path structure and indicator choice still needs lecturer confirmation. No causal claim is made.

The focused SQ2 and updated 17-cell SEM notebook executed without cell errors. Full group notebook execution is not certified by this update.

## Exploratory clustering

Business_Statistics_Clustering.ipynb follows the course K-means example, adapted to four observed survey items: awareness, control, influence and the reverse-coded algorithm-decides item. Age is excluded from clustering and described afterwards. Features are z-scaled and k=2 to 10 compared; No cluster count is fixed in advance; only the provisional highest-silhouette solution is profiled. All 8 cells executed on 669 complete records. k=9 has the highest silhouette (0.299, DBI=1.180, minimum cluster n=21); Random-start agreement for k=9 ranges from ARI 0.609 to 0.894, so a unique stable solution is not established. No confirmatory hypothesis test or causal claim follows. DBSCAN/HDBSCAN were not fitted. The earlier Google Doc predates this clustering addition.


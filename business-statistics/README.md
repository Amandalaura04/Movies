# Business Statistics — SQ2

Updated for the group's 30 October 2026 question: “How does content personalization influence users' perceived control over their social media feeds across different age groups?”

- `Business_Statistics_SQ2.ipynb` is Amanda Luijendijk's current analysis, aligned with the SQ2 section in the shared group notebook.
- [Shared group notebook](https://colab.research.google.com/drive/1qGZsNhBEB7gmZtuy59oYEtWoXefIS7x5) contains the group's existing work plus the updated SQ2 section.
- `Business_Statistics_SEM.ipynb` is the earlier exploratory analysis. It does not answer the updated personalisation question and is not the primary SQ2 result.

## Run

Install `requirements.txt`. Place your authorised `Responses.xlsx` beside the notebook, or set `BS_DATA_PATH` to its location. The loader also checks the earlier Downloads filename and the shared Colab Notebooks folder in mounted Google Drive. Run all cells from top to bottom.

No raw survey data or respondent-level outputs are included in GitHub. Public notebooks have saved outputs cleared. The shared notebook retains aggregate SQ2 results.

## Measurement and results

The survey does not directly measure the amount of personalisation. SQ2 uses awareness of personal-data-based feed shaping as a limited proxy, with a single perceived-control item as the outcome. The notebook states this mismatch explicitly. Causal effects of personalisation cannot be estimated from these data.

The analysis uses age categories, an age-adjusted OLS model with HC3 standard errors, an ordinal Spearman sensitivity check, and an exploratory interaction model. OLS treats the five response categories as equally spaced. No age groups are merged after inspecting results.

Validated on 1 November 2026 against the shared Responses.xlsx: 685 rows, 57 columns; 673 complete SQ2 responses. Both the full 99-cell group notebook and the focused 23-cell SQ2 notebook executed without cell errors.

The awareness coefficient is -0.027 (95% HC3 CI -0.116 to 0.061; p=0.543). The exploratory interaction has p=0.0000725, but sparse age groups limit interpretation. These are different hypotheses; a nonsignificant overall coefficient does not rule out variation by age. The notebook generates its conclusion from the executed results.

The provisional three-question Bonferroni correction is labelled as provisional. Agree the final family of confirmatory tests with the group. SQ1 and SQ3 are not completed or validated as final analyses by this update.

Prepared with Codex assistance. Review the measurement choices, recruitment assumptions, code and conclusions, and explain your own contribution before submission.

Amanda Luijendijk’s section includes simple English explanations and supporting rank/scaling work, the earlier age-group comparison, and the model including social media use. Earlier SEM work remains separate and is not used as evidence for the updated question.

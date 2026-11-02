# Business Statistics — Amanda Luijendijk

## Main notebook

`Business_Statistics_SQ2.ipynb` now contains Amanda's full SQ2 in simple English. It has 22 cells, including 10 code cells (170 code lines, reduced from 451). The main story covers data preparation, three-category chi-square, awareness/control regression and age interaction, exploratory SEM, K-means clustering and a short conclusion. Ranking/scaling, extra age tests, fit checks and cluster stability are in the appendix. Simple figures stay beside the results.

Question: How is awareness of feed personalisation related to perceived control, and does this relationship differ across age groups?

## Run

Install requirements.txt. Place an authorised Responses.xlsx beside the notebook, set BS_DATA_PATH, or mount the shared Google Drive folder. Run all cells in order. The raw survey is not stored in GitHub; public outputs are cleared.

The shared group notebook contains the same compact Amanda block: https://colab.research.google.com/drive/1qGZsNhBEB7gmZtuy59oYEtWoXefIS7x5

## Checks and limits

The full compact notebook executed without cell errors on 685 source responses. Main regression N=673, p=0.543439; exploratory age interaction p=0.0000724794. Three-category chi-square N=674, chi-square(4)=8.596, p=0.0720292. SEM N=669, alpha=0.481, awareness estimate=0.090, unadjusted p=0.00569027. Clustering N=669, provisional k=9, silhouette=0.299, random-start agreement ARI 0.609–0.894. Extra age and use-frequency results also match the earlier verified version.

The code is shorter, but measurement has not become stronger. Awareness is not actual personalisation; the SEM scale is weak, small age groups limit interaction estimates, and the cluster count is provisional. No causal claim is made. The final multiple-testing family and the course interpretation of two meaningful SEM paths still need group/lecturer agreement. Other group members' code is not certified by this check.

The separate SEM and Clustering notebooks retain more detailed technical versions of the same analyses. The earlier Google Doc predates the compact layout and clustering additions.

Prepared with Codex assistance. Review the code, credit adapted course SEM and clustering examples, and explain your own contribution before submission. SEM reference: https://semopy.com/tutorial.html

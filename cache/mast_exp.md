1) https://www.internalfb.com/mast/job/fire-xlwang-0602-cc38e382-hstu
2) https://www.internalfb.com/mast/job/fire-xlwang-0607-55d6083b-cot_raw_aiayn_5moe
3) https://www.internalfb.com/mast/job/fire-xlwang-0614-ce884d21-cot_raw_aiayn_3ffmoev2_l4w512h4
    ne gain started 30G
4) https://www.internalfb.com/mast/job/fire-xlwang-0613-4a68f2ab-cot_raw_aiayn_3ffmoe_l4w512h4
    qps slow (3.8e4 vs 4.1e5, whole ff moe, packed)
5) https://www.internalfb.com/mast/job/fire-xlwang-0611-1588adaa-cot_raw_aiayn_5moe_l4w512h4_dp_opt
    qps (1.13e5 vs 4.04e5), ne slightly better at 70G
6) https://www.internalfb.com/mast/job/fire-xlwang-0611-9835cdc3-cot_raw_aiayn_5moe_l12w512h4_dp
    qps 4.26e4, no significantly change in ne
7) https://www.internalfb.com/mast/job/fire-xlwang-0607-29185f86-cot_raw_aiayn_10moe_l8w256h4
    5.52e4, worse ne
   https://fburl.com/tensorboard/jbloy0fr


https://www.internalfb.com/mast/job/fire-xlwang-0611-5b4e2d25-cot_raw_aiayn_5moe_l4w512h4_dp (NEX)
https://www.internalfb.com/mast/job/fire-xlwang-0611-a2a79e3f-cot_raw_aiayn_5moe_l8w512h4_dp
https://www.internalfb.com/mast/job/fire-xlwang-0611-9835cdc3-cot_raw_aiayn_5moe_l12w512h4_dp
(started to outperform at 15G, but is it overfitting)
https://www.internalfb.com/mast/job/fire-xlwang-0607-29185f86-cot_raw_aiayn_10moe_l8w256h4 (neutral to hstu)
https://www.internalfb.com/mast/job/fire-xlwang-0607-55d6083b-cot_raw_aiayn_5moe
https://www.internalfb.com/mast/job/fire-xlwang-0602-cc38e382-hstu
https://www.internalfb.com/mast/job/fire-xlwang-0602-a7bf1038-CoTExp25RO_inject_raw
https://fburl.com/tensorboard/n8sn7nvo
fire-xlwang-0611-1588adaa-cot_raw_aiayn_5moe_l4w512h4_dp_opt
(catchup to outperform at 50G)
fire-xlwang-0611-6b1f1740-cot_raw_aiayn_5moe_l12w512h4_dp_opt
(large NE variance compared to hstu, indicating overfitting? not consistent to non-opt
version above)



# mem snapshot

fire-xlwang-0610-708f2d1d-cot_raw_aiayn_5moe_l8w512h4_dp (oom)
https://fburl.com/pytorch_memory_visualizer/jfdkgqwq

fire-xlwang-0607-29185f86-cot_raw_aiayn_10moe_l8w256h4 (working)
https://fburl.com/pytorch_memory_visualizer/vo2brnx4

fire-xlwang-0610-2fc06afd-cot_raw_aiayn_5moe_l8w512h4_dp (fix) - peak 71G
https://fburl.com/pytorch_memory_visualizer/23rldqvu

fire-xlwang-0607-29185f86-cot_raw_aiayn_10moe_l8w256h4 - peak 61G
https://fburl.com/pytorch_memory_visualizer/zir3c4j1

fire-xlwang-0611-1588adaa-cot_raw_aiayn_5moe_l4w512h4_dp_opt - peak 72G
https://fburl.com/pytorch_memory_visualizer/r61kz8e2

fire-xlwang-0610-019f0600-cot_raw_aiayn_5moe_l12w512h4_dp (oom)
fire-xlwang-0607-55d6083b-cot_raw_aiayn_5moe (working)

# moe, deep x patch
1) https://www.internalfb.com/mast/job/fire-xlwang-0610-f6eeb025-cot_raw_aiayn_5moe_l4w512h2_dp
2) https://www.internalfb.com/mast/job/fire-xlwang-0610-4b8b4336-cot_raw_aiayn_5moe_l12w512h4_dp
3) https://www.internalfb.com/mast/job/fire-xlwang-0610-c1136e45-cot_raw_aiayn_5moe_l8w512h4_dp
4) https://www.internalfb.com/mast/job/fire-xlwang-0607-29185f86-cot_raw_aiayn_10moe_l8w256h4
5) https://www.internalfb.com/mast/job/fire-xlwang-0607-55d6083b-cot_raw_aiayn_5moe
6) https://www.internalfb.com/mast/job/fire-xlwang-0602-cc38e382-hstu
7) https://www.internalfb.com/mast/job/fire-xlwang-0602-a7bf1038-CoTExp25RO_inject_raw
   https://fburl.com/tensorboard/kzvf0907



# moe vs hstu
   1) https://www.internalfb.com/mast/job/fire-xlwang-0607-55d6083b-cot_raw_aiayn_5moe
   2) https://www.internalfb.com/mast/job/fire-xlwang-0602-cc38e382-hstu
 https://fburl.com/tensorboard/lxtfmf6g


# 6/10 aiayn
https://www.internalfb.com/mast/job/fire-xlwang-0607-29185f86-cot_raw_aiayn_10moe_l8w256h4
https://www.internalfb.com/mast/job/fire-xlwang-0607-5b083327-cot_raw_aiayn_10moe_l8w256h4
https://www.internalfb.com/mast/job/fire-xlwang-0607-55d6083b-cot_raw_aiayn_5moe PRO
https://www.internalfb.com/mast/job/fire-xlwang-0607-dfdea88b-cot_raw_aiayn NEX
https://www.internalfb.com/mast/job/fire-xlwang-0606-a16b96b0-cot_raw_aiayn_5moe_l4w128h4 NEX
https://www.internalfb.com/mast/job/fire-xlwang-0606-f34aa762-cot_raw_aiayn_5moe_large_gating NEX
https://www.internalfb.com/mast/job/fire-xlwang-0606-9fa7b64c-cot_raw_aiayn NEX
https://www.internalfb.com/mast/job/fire-xlwang-0606-52a18554-cot_raw_aiayn_5moe_ac_small_gating
https://www.internalfb.com/mast/job/fire-xlwang-0602-cc38e382-hstu
https://www.internalfb.com/mast/job/fire-xlwang-0602-a7bf1038-CoTExp25RO_inject_raw
https://fburl.com/tensorboard/izg9fzr2

# moe
https://www.internalfb.com/mast/job/fire-xlwang-0606-a16b96b0-cot_raw_aiayn_5moe_l4w128h4
https://www.internalfb.com/mast/job/fire-xlwang-0606-f34aa762-cot_raw_aiayn_5moe_large_gating
https://www.internalfb.com/mast/job/fire-xlwang-0606-9fa7b64c-cot_raw_aiayn
https://www.internalfb.com/mast/job/fire-xlwang-0606-52a18554-cot_raw_aiayn_5moe_ac_small_gating
https://www.internalfb.com/mast/job/fire-xlwang-0602-cc38e382-hstu
https://www.internalfb.com/mast/job/fire-xlwang-0602-a7bf1038-CoTExp25RO_inject_raw
https://fburl.com/tensorboard/zam239x0


# moe
moe has unexpected NE jump but recoverable, but not to the baseline level
https://www.internalfb.com/mast/job/fire-xlwang-0606-52a18554-cot_raw_aiayn_5moe_ac_small_gating
https://www.internalfb.com/mast/job/fire-xlwang-0606-2abfe875-cot_raw_aiayn_5moe_ac_gating
https://www.internalfb.com/mast/job/fire-xlwang-0603-edd83c9a-CoTExp25ROContextual_raw_aiayn
https://www.internalfb.com/mast/job/fire-xlwang-0602-cc38e382-hstu
https://www.internalfb.com/mast/job/fire-xlwang-0602-a7bf1038-CoTExp25RO_inject_raw
https://fburl.com/tensorboard/6euduaf2


# inject and contextual
# train: 5/25
https://www.internalfb.com/mast/job/fire-xlwang-0602-cc38e382-hstu
https://www.internalfb.com/mast/job/fire-xlwang-0602-662f3184-CoTExp25ROContextual_raw
https://www.internalfb.com/mast/job/fire-xlwang-0602-bff1790f-CoTExp25ROContextual_mlp
https://www.internalfb.com/mast/job/fire-xlwang-0602-a7bf1038-CoTExp25RO_inject_raw
https://fburl.com/tensorboard/zte8qdn7


# 2024-05-20
# --eval-start-ts 2024-05-14+08:00:00 --eval-end-ts 2024-05-14+12:00:00

https://www.internalfb.com/mast/job/fire-xlwang-0530-a273534f-CoTExp25RO3MoE
https://www.internalfb.com/mast/job/fire-xlwang-0530-a6a5b1be-CoTExp25RO6SGMoE
https://www.internalfb.com/mast/job/fire-xlwang-0527-b53b3b02-cot_exp_25ro
https://www.internalfb.com/mast/job/fire-xlwang-0520-719b9c91-hstu
https://www.internalfb.com/mast/job/fire-xlwang-0530-d0735e70-CoTExp25RO_inject_mlp
https://www.internalfb.com/mast/job/fire-xlwang-0530-3b9f79d5-CoTExp25RO_inject_raw
https://www.internalfb.com/mast/job/fire-xlwang-0531-3947ad52-CoTExp25ROContextual_raw
https://www.internalfb.com/mast/job/fire-xlwang-0531-4fd819b7-CoTExp25ROContextual_mlp
https://fburl.com/tensorboard/ce3ft921


-- MLP
https://www.internalfb.com/mast/job/fire-xlwang-0530-a273534f-CoTExp25RO3MoE
https://www.internalfb.com/mast/job/fire-xlwang-0530-a6a5b1be-CoTExp25RO6SGMoE
https://www.internalfb.com/mast/job/fire-xlwang-0527-b53b3b02-cot_exp_25ro
https://www.internalfb.com/mast/job/fire-xlwang-0520-719b9c91-hstu
https://www.internalfb.com/mast/job/fire-xlwang-0530-d0735e70-CoTExp25RO_inject_mlp
https://www.internalfb.com/mast/job/fire-xlwang-0530-3b9f79d5-CoTExp25RO_inject_raw
https://fburl.com/tensorboard/txmybvva


-- MOE
https://www.internalfb.com/mast/job/fire-xlwang-0529-ad4edaa5-cot_exp_25ro_6sgmoe
https://www.internalfb.com/mast/job/fire-xlwang-0528-bae0a453-cot_exp_25ro (3MOE)
https://www.internalfb.com/mast/job/fire-xlwang-0527-b53b3b02-cot_exp_25ro
https://www.internalfb.com/mast/job/fire-xlwang-0524-cd2b8e40-cot_exp_5ro
https://www.internalfb.com/mast/job/fire-xlwang-0520-719b9c91-hstu
https://fburl.com/tensorboard/1qryhj6h


-- Long/Sample
https://www.internalfb.com/mast/job/fire-xlwang-0520-719b9c91-hstu
https://www.internalfb.com/mast/job/fire-xlwang-0520-e102b1f8-cot_exp_long_samp
https://www.internalfb.com/mast/job/fire-xlwang-0520-57b2b215-cot_exp_extreme_samp
https://www.internalfb.com/mast/job/fire-xlwang-0523-1374b2c8-cot_exp_long_samp30
https://www.internalfb.com/mast/job/fire-xlwang-0523-e3072f70-cot_exp_long_samp2
https://www.internalfb.com/mast/job/fire-xlwang-0524-cd2b8e40-cot_exp_5ro
https://fburl.com/tensorboard/4z2fbaeb

# 2024-05-20
# --eval-start-ts 2024-05-14+08:00:00 --eval-end-ts 2024-05-14+12:00:00
```
https://www.internalfb.com/mast/job/fire-xlwang-0520-719b9c91-hstu
https://www.internalfb.com/mast/job/fire-xlwang-0520-d0ef0eb0-cot_prod
https://www.internalfb.com/mast/job/fire-xlwang-0520-e102b1f8-cot_exp_long_samp
https://www.internalfb.com/mast/job/fire-xlwang-0520-57b2b215-cot_exp_extreme_samp
https://www.internalfb.com/mast/job/fire-xlwang-0520-4768608c-cot_exp_long_last
https://www.internalfb.com/mast/job/fire-xlwang-0523-1374b2c8-cot_exp_long_samp30
https://www.internalfb.com/mast/job/fire-xlwang-0523-e3072f70-cot_exp_long_samp2
https://fburl.com/tensorboard/7z3rcevz
```

# 2024-05-16
# --eval-start-ts 2024-05-03+08:00:00 --eval-end-ts 2024-05-03+12:00:00
# QPS:
#   prod 4.18e5
#   hstu 3.34e5
# hit:
#   prod 0.89
#   exp 0.85
#   long_samp 0.83
#   extreme_samp 0.81
```
https://www.internalfb.com/mast/job/fire-xlwang-0510-0e2bdecf-hstu (0.7921)
https://www.internalfb.com/mast/job/fire-xlwang-0515-d60bcc6f-hstu2 (0.7906)
https://www.internalfb.com/mast/job/fire-xlwang-0515-35ffc52f-cot_prod
https://www.internalfb.com/mast/job/fire-xlwang-0515-e6a139bf-cot_exp (0.7921)
https://www.internalfb.com/mast/job/fire-xlwang-0515-88191aca-cot_exp_long_samp
https://www.internalfb.com/mast/job/fire-xlwang-0515-1a52f7a0-cot_prod2 (0.7859)
https://www.internalfb.com/mast/job/fire-xlwang-0516-f6c561ed-cot_exp_extreme_samp
https://www.internalfb.com/mast/job/fire-xlwang-0517-3b92bf77-cot_prod3
https://fburl.com/tensorboard/5b0pq375
```


# Metrics
---
variable_step_metrics/NE/global/window/vvp100/(train|eval)
variable_step_qps/global/lifetime/(train|eval)
variable_step_metrics/NE/global/window/(mt/)?(comment|like|vvd|share|vv[^/_]*)/(train|eval)
user_export/enrichment_index_hit/mean/(train|eval)
user_export/enriched_.*_len/mean/train

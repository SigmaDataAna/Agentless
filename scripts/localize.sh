#!/bin/bash

# python agentless/fl/localize.py --file_level \
#                                 --model=deepseek-ai/DeepSeek-R1-Distill-Qwen-7B \
#                                 --backend=openai \
#                                 --output_folder ../swe_data/agentless_results \
#                                 --skip_existing \
#                                 --target_id=django__django-10914

# python agentless/fl/localize.py --file_level \
#                                 --model=deepseek-ai/DeepSeek-R1-Distill-Qwen-7B \
#                                 --backend=openai \
#                                 --irrelevant \
#                                 --output_folder ../swe_data/agentless_results_irrelevant \
#                                 --num_threads 10 \
#                                 --skip_existing \
#                                 --target_id=django__django-10914

# python agentless/fl/retrieve.py --index_type simple \
#                                 --filter_type given_files \
#                                 --filter_file ../swe_data/agentless_results_irrelevant/loc_outputs.jsonl \
#                                 --output_folder ../swe_data/retrievel_embedding \
#                                 --persist_dir embedding/swe-bench_simple \
#                                 --num_threads 10 \
#                                 --target_id=django__django-10914

# python agentless/fl/combine.py  --retrieval_loc_file ../swe_data/retrievel_embedding/retrieve_locs.jsonl \
#                                 --model_loc_file ../swe_data/agentless_results/loc_outputs.jsonl \
#                                 --top_n 3 \
#                                 --output_folder ../swe_data/file_level_combined 

# python agentless/fl/localize.py --related_level \
#                                 --model=deepseek-ai/DeepSeek-R1-Distill-Qwen-7B \
#                                 --backend=openai \
#                                 --output_folder ../swe_data/related_elements \
#                                 --top_n 3 \
#                                 --compress_assign \
#                                 --compress \
#                                 --start_file ../swe_data/file_level_combined/combined_locs.jsonl \
#                                 --num_threads 10 \
#                                 --skip_existing \
#                                 --target_id=django__django-10914


# python agentless/fl/localize.py --fine_grain_line_level \
#                                 --model=deepseek-ai/DeepSeek-R1-Distill-Qwen-7B \
#                                 --backend=openai \
#                                 --output_folder ../swe_data/edit_location_samples \
#                                 --top_n 3 \
#                                 --compress \
#                                 --temperature 0.8 \
#                                 --num_samples 4 \
#                                 --start_file ../swe_data/related_elements/loc_outputs.jsonl \
#                                 --num_threads 10 \
#                                 --skip_existing \
#                                 --target_id=django__django-10914

# python agentless/fl/localize.py --merge \
#                                 --model=deepseek-ai/DeepSeek-R1-Distill-Qwen-7B \
#                                 --backend=openai \
#                                 --output_folder ../swe_data/edit_location_individual \
#                                 --top_n 3 \
#                                 --num_samples 4 \
#                                 --start_file ../swe_data/edit_location_samples/loc_outputs.jsonl 

python agentless/repair/repair.py --loc_file ../swe_data/edit_location_individual/loc_merged_1-1_outputs.jsonl \
                                  --output_folder ../swe_data/repair_sample_2 \
                                  --loc_interval \
                                  --top_n=3 \
                                  --context_window=10 \
                                  --max_samples 10  \
                                  --cot \
                                  --diff_format \
                                  --gen_and_process \
                                  --num_threads 2 \
                                  --target_id=django__django-10914

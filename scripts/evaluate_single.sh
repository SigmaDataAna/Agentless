#!/bin/bash

export OPENAI_API_KEY="EMPTY"
export PYTHONPATH=$PYTHONPATH:$(pwd)

export GENERATE_MODEL_URL="http://127.0.0.1:8000/v1"
export RETRIEVE_MODEL_URL="http://127.0.0.1:8000/v1"
export GENERATE_MODEL='deepseek-ai/DeepSeek-R1-Distill-Qwen-7B'
export RETRIEVE_MODEL='deepseek-ai/DeepSeek-R1-Distill-Qwen-7B'

export TASK_ID="django__django-10914"

python agentless/fl/localize.py --file_level \
                                --model=${GENERATE_MODEL} \
                                --backend=openai \
                                --output_folder ${OUTPUT_DIR}/agentless_results \
                                --skip_existing \
                                --target_id=${TASK_ID}

python agentless/fl/localize.py --file_level \
                                --model=${GENERATE_MODEL} \
                                --backend=openai \
                                --irrelevant \
                                --output_folder ${OUTPUT_DIR}/agentless_results_irrelevant \
                                --num_threads 10 \
                                --skip_existing \
                                --target_id=${TASK_ID}

python agentless/fl/retrieve.py --index_type simple \
                                --filter_type given_files \
                                --filter_file ${OUTPUT_DIR}/agentless_results_irrelevant/loc_outputs.jsonl \
                                --output_folder ${OUTPUT_DIR}/retrievel_embedding \
                                --persist_dir embedding/swe-bench_simple \
                                --num_threads 10 \
                                --target_id=${TASK_ID}

python agentless/fl/combine.py  --retrieval_loc_file ${OUTPUT_DIR}/retrievel_embedding/retrieve_locs.jsonl \
                                --model_loc_file ${OUTPUT_DIR}/agentless_results/loc_outputs.jsonl \
                                --top_n 3 \
                                --output_folder ${OUTPUT_DIR}/file_level_combined 

python agentless/fl/localize.py --related_level \
                                --model=${GENERATE_MODEL} \
                                --backend=openai \
                                --output_folder ${OUTPUT_DIR}/related_elements \
                                --top_n 3 \
                                --compress_assign \
                                --compress \
                                --start_file ${OUTPUT_DIR}/file_level_combined/combined_locs.jsonl \
                                --num_threads 10 \
                                --skip_existing \
                                --target_id=${TASK_ID}


python agentless/fl/localize.py --fine_grain_line_level \
                                --model=${GENERATE_MODEL} \
                                --backend=openai \
                                --output_folder ${OUTPUT_DIR}/edit_location_samples \
                                --top_n 3 \
                                --compress \
                                --temperature 0.8 \
                                --num_samples 4 \
                                --start_file ${OUTPUT_DIR}/related_elements/loc_outputs.jsonl \
                                --num_threads 10 \
                                --skip_existing \
                                --target_id=${TASK_ID}

python agentless/fl/localize.py --merge \
                                --model=${GENERATE_MODEL} \
                                --backend=openai \
                                --output_folder ${OUTPUT_DIR}/edit_location_individual \
                                --top_n 3 \
                                --num_samples 4 \
                                --start_file ${OUTPUT_DIR}/edit_location_samples/loc_outputs.jsonl 

python agentless/repair/repair.py --loc_file ${OUTPUT_DIR}/edit_location_individual/loc_merged_0-0_outputs.jsonl \
                                  --output_folder ${OUTPUT_DIR}/repair_sample_0 \
                                  --loc_interval \
                                  --top_n=3 \
                                  --context_window=10 \
                                  --max_samples 10  \
                                  --cot \
                                  --diff_format \
                                  --gen_and_process \
                                  --num_threads 2 \
                                  --target_id=${TASK_ID}

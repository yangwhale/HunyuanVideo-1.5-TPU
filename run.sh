export T2V_REWRITE_BASE_URL="<your_vllm_server_base_url>"
export T2V_REWRITE_MODEL_NAME="<your_model_name>"
export I2V_REWRITE_BASE_URL="<your_vllm_server_base_url>"
export I2V_REWRITE_MODEL_NAME="<your_model_name>"

PROMPT='A girl holding a paper with words "Hello, world!"'

IMAGE_PATH=none # 可选，none 或 <图像路径> 以启用 i2v 模式
SEED=1
ASPECT_RATIO=16:9
RESOLUTION=480p
OUTPUT_PATH=./outputs/output.mp4

# 配置
REWRITE=false # 启用提示词重写。请确保 rewrite vLLM server 已部署和配置。
N_INFERENCE_GPU=8 # 并行推理 GPU 数量
CFG_DISTILLED=true # 使用 CFG 蒸馏模型进行推理，2倍加速
SPARSE_ATTN=false # 使用稀疏注意力进行推理（仅 720p 模型配备了稀疏注意力）。请确保 flex-block-attn 已安装
SAGE_ATTN=false # 使用 SageAttention 进行推理
OVERLAP_GROUP_OFFLOADING=true # 仅在组卸载启用时有效，会显著增加 CPU 内存占用，但能够提速
ENABLE_CACHE=true # 启用特征缓存进行推理。显著提升推理速度
CACHE_TYPE=deepcache # 支持：deepcache, teacache, taylorcache
ENABLE_SR=true # 启用超分辨率
MODEL_PATH=/dev/shm/HunyuanVideo-1.5/ckpts # 预训练模型路径（使用内存文件系统）

~/.local/bin/torchrun --nproc_per_node=$N_INFERENCE_GPU generate.py \
  --prompt "$PROMPT" \
  --image_path $IMAGE_PATH \
  --resolution $RESOLUTION \
  --aspect_ratio $ASPECT_RATIO \
  --seed $SEED \
  --rewrite $REWRITE \
  --cfg_distilled $CFG_DISTILLED \
  --sparse_attn $SPARSE_ATTN --use_sageattn $SAGE_ATTN \
  --enable_cache $ENABLE_CACHE --cache_type $CACHE_TYPE \
  --overlap_group_offloading $OVERLAP_GROUP_OFFLOADING \
  --sr $ENABLE_SR --save_pre_sr_video \
  --output_path $OUTPUT_PATH \
  --model_path $MODEL_PATH
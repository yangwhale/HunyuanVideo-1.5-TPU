# HunyuanVideo-1.5-TPU 完整安装指南

本文档提供在全新系统上安装 HunyuanVideo-1.5-TPU 的完整步骤。本指南使用 PyTorch 最新稳定版本和对应的 CUDA 版本。

## 系统要求

- Ubuntu 24.04 LTS
- NVIDIA GPU（建议 H100 或 A100）
- 至少 200GB 可用磁盘空间（用于模型文件）
- Python 3.12

## 1. 基础环境准备

### 1.1 安装基础包

```bash
sudo apt update
sudo apt install -y python-is-python3 python3-pip build-essential wget git
```

### 1.2 配置 pip

创建 `~/.config/pip/pip.conf`：

```bash
mkdir -p ~/.config/pip
cat > ~/.config/pip/pip.conf << 'EOF'
[global]
break-system-packages = true
EOF
```

## 2. 安装 CUDA 12.9

**重要**：系统已预装 NVIDIA 驱动，此步骤仅安装 CUDA Toolkit。

### 从 NVIDIA 官方下载安装 CUDA 12.9

访问 [NVIDIA CUDA Toolkit 下载页面](https://developer.nvidia.com/cuda-downloads)，选择 CUDA 12.9。

```bash
cd ~
wget https://developer.download.nvidia.com/compute/cuda/12.9.0/local_installers/cuda_12.9.0_560.35.05_linux.run
sudo sh cuda_12.9.0_560.35.05_linux.run --silent --toolkit --toolkitpath=/usr/local/cuda-12.9
```

**注意**：如果下载链接有变化，请访问 [NVIDIA CUDA Archive](https://developer.nvidia.com/cuda-toolkit-archive) 获取 CUDA 12.9 的最新下载链接。

### 2.1 配置 CUDA 环境变量

在 `~/.bashrc` 末尾添加：

```bash
cat >> ~/.bashrc << 'EOF'

# CUDA 12.9 环境变量
export CUDA_HOME=/usr/local/cuda-12.9
export PATH=$CUDA_HOME/bin:$PATH
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH
EOF

source ~/.bashrc
```

### 2.2 验证 CUDA 安装

```bash
nvcc --version  # 应显示 release 12.9
nvidia-smi      # 应显示 GPU 信息和驱动版本
```

## 3. 安装 PyTorch 2.8.0 (CUDA 12.9)

官方要求：`torch>=2.6.0`。我们使用 PyTorch 2.8.0 配合 CUDA 12.9。

```bash
pip install torch==2.8.0+cu129 torchvision==0.23.0+cu129 --index-url https://download.pytorch.org/whl/cu129
```

**⚠️ 重要提示**：安装requirements.txt时，由于依赖约束，PyTorch可能会被降级到2.6.0+cu124。这是正常现象，2.6.0满足项目要求（>=2.6.0）且完全兼容。如需保持2.8.0版本，请在安装requirements.txt后重新安装。

**注意**：如果遇到版本不存在的错误，可以尝试：
```bash
# 方案 1：安装最新的 cu129 版本
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu129

# 方案 2：访问 PyTorch 官网获取最新命令
# https://pytorch.org/get-started/locally/
```

### 3.1 验证 PyTorch 安装

```bash
python -c "import torch; print('PyTorch:', torch.__version__); print('CUDA:', torch.version.cuda); print('GPU Available:', torch.cuda.is_available())"
```

应输出类似：
```
PyTorch: 2.8.0+cu129 (或 2.6.0+cu124)
CUDA: 12.9 (或 12.4)
GPU Available: True
```

## 4. 克隆并安装 HunyuanVideo-1.5-TPU

### 4.1 克隆仓库

```bash
cd ~
git clone https://github.com/Tencent/HunyuanVideo HunyuanVideo-1.5-TPU
cd HunyuanVideo-1.5-TPU
```

### 4.2 安装 Python 依赖

```bash
pip install -r requirements.txt
pip install tencentcloud-sdk-python
```

## 5. 从源码编译 Flash Attention

**关键步骤**：必须在 CUDA 12.9 环境下编译，并强制从源码构建以确保ABI兼容性。

```bash
# 确保 CUDA 12.9 环境变量正确设置并强制从源码编译
export CUDA_HOME=/usr/local/cuda-12.9
export PATH=$CUDA_HOME/bin:$PATH
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH
export FLASH_ATTENTION_FORCE_BUILD=TRUE
export TORCH_CUDA_ARCH_LIST="9.0"

# 从源码编译 Flash Attention（约5-10分钟，请耐心等待）
pip install flash-attn --no-build-isolation --no-cache-dir
```

**重要说明**：
- `FLASH_ATTENTION_FORCE_BUILD=TRUE` 强制从源码编译，避免使用预编译wheel
- `TORCH_CUDA_ARCH_LIST="9.0"` 为H100 GPU指定计算能力
- 编译时间约 5-10 分钟，请耐心等待不要中断

### 5.1 验证 Flash Attention

```bash
python -c "import flash_attn; print('Flash Attention installed successfully')"
```

## 6. （可选）安装 flex-block-attn

**注意**：默认情况下 `run.sh` 中 `SPARSE_ATTN=false`，所以此步骤是可选的。

如果需要稀疏注意力功能（仅 720p 模型），执行以下步骤：

```bash
cd ~
git clone https://github.com/microsoft/FLEX-BLOCK-ATTN flex-block-attn
cd flex-block-attn
git submodule update --init --recursive

# 确保 CUDA 12.9 环境变量正确设置
export CUDA_HOME=/usr/local/cuda-12.9
export PATH=$CUDA_HOME/bin:$PATH
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH

# 编译安装
pip install -e . --no-build-isolation
```

## 7. 下载模型文件

### 7.1 安装下载工具

```bash
pip install -U "huggingface_hub[cli]" modelscope
```

### 7.2 配置 HuggingFace 环境变量

获取HuggingFace Token：访问 https://huggingface.co/settings/tokens

在 `~/.bashrc` 中添加：

```bash
cat >> ~/.bashrc << 'EOF'

# HuggingFace 配置
export HF_HOME=/dev/shm/huggingface  # 使用内存文件系统，提升性能
export HF_TOKEN=your_huggingface_token_here  # 替换为实际token
EOF

source ~/.bashrc
```

### 7.3 下载模型文件（约360GB，需要时间）

**注意**：所有模型将下载到 `/dev/shm/HunyuanVideo-1.5/ckpts/` 目录（使用内存文件系统以提升性能）

#### 7.3.1 GCS 快速下载（推荐）

如果您有 Google Cloud Storage 访问权限，可以使用此方法快速下载预打包的模型：

```bash
# 安装 gcloud CLI（如果尚未安装）
# 参考：https://cloud.google.com/sdk/docs/install

# 从 GCS 下载完整模型包（约360GB，包含所有必需模型）
gcloud storage cp -r gs://chrisya-gpu-pg-ase1/HunyuanVideo-1.5 /dev/shm/

# 创建软链接到项目目录（可选，便于访问）
cd ~/HunyuanVideo-1.5-TPU
ln -sf /dev/shm/HunyuanVideo-1.5/ckpts ./ckpts
```

**优势**：
- 下载速度快（使用 Google Cloud 高速网络）
- 一次下载完整模型包，无需分步骤下载
- 自动验证数据完整性

#### 7.3.2 从源下载（HuggingFace/ModelScope）

如果无法访问 GCS，可以使用此方法从官方源逐个下载模型：

**Text-to-Video 必需模型：**

```bash
# 1. 主模型文件 (~338GB)
hf download tencent/HunyuanVideo-1.5 --local-dir /dev/shm/HunyuanVideo-1.5/ckpts

# 2. 文本编码器 Qwen2.5-VL-7B-Instruct (~16.6GB)
hf download Qwen/Qwen2.5-VL-7B-Instruct --local-dir /dev/shm/HunyuanVideo-1.5/ckpts/text_encoder/llm

# 3. byT5编码器 (~3.6GB)
hf download google/byt5-small --local-dir /dev/shm/HunyuanVideo-1.5/ckpts/text_encoder/byt5-small

# 4. Glyph-SDXL-v2 (~1.5GB，仅ModelScope提供)
modelscope download --model AI-ModelScope/Glyph-SDXL-v2 --local_dir /dev/shm/HunyuanVideo-1.5/ckpts/text_encoder/Glyph-SDXL-v2

# 创建软链接到项目目录
cd ~/HunyuanVideo-1.5-TPU
ln -sf /dev/shm/HunyuanVideo-1.5/ckpts ./ckpts
```

**Vision Encoder（必需模型，约1GB）：**

尽管Vision Encoder主要用于Image-to-Video功能，但即使在Text-to-Video模式下也需要加载此模型。

需要先申请访问权限：
1. 访问 https://huggingface.co/black-forest-labs/FLUX.1-Redux-dev
2. 点击"Request Access"按钮并等待批准（通常几分钟内批准）
3. 批准后执行下载：

```bash
# 5. Vision Encoder - FLUX.1-Redux-dev (~1GB)
hf download black-forest-labs/FLUX.1-Redux-dev --local-dir /dev/shm/HunyuanVideo-1.5/ckpts/vision_encoder/siglip --token $HF_TOKEN
```

**注意**：如果跳过此步骤，运行时会报错：`FileNotFoundError: /dev/shm/HunyuanVideo-1.5/ckpts/vision_encoder/siglip not found`

**下载提示：**
- 所有下载工具支持断点续传，中断后重新运行命令即可继续
- HuggingFace下载慢可使用镜像：`HF_ENDPOINT=https://hf-mirror.com`
- ModelScope下载使用的是中国镜像，速度通常较快

## 8. 配置运行脚本

### 8.1 确保模型路径软链接已创建

如果您按照第7节的方法下载了模型到 `/dev/shm/HunyuanVideo-1.5/ckpts/`，需要创建软链接：

```bash
cd ~/HunyuanVideo-1.5-TPU
ln -sf /dev/shm/HunyuanVideo-1.5/ckpts ./ckpts
```

验证软链接：
```bash
ls -l ./ckpts  # 应显示: ckpts -> /dev/shm/HunyuanVideo-1.5/ckpts
```

**注意**：`run.sh` 中的 `MODEL_PATH=ckpts` 会通过此软链接指向 `/dev/shm/HunyuanVideo-1.5/ckpts/`

### 8.2 修改 run.sh

编辑 `~/HunyuanVideo-1.5-TPU/run.sh`：

```bash
# 禁用提示词重写（无需 vLLM 服务器）
REWRITE=false

# 配置 GPU 数量（根据实际情况调整）
N_INFERENCE_GPU=8  # 如果是 8x H100

# 其他配置保持默认
# MODEL_PATH=ckpts  # 已通过软链接指向 /dev/shm/HunyuanVideo-1.5/ckpts/
```

### 8.3 修改 torchrun 路径

在 `run.sh` 中，将 `torchrun` 改为完整路径：

```bash
# 原来的：
torchrun --nproc_per_node=$N_INFERENCE_GPU generate.py \

# 改为：
~/.local/bin/torchrun --nproc_per_node=$N_INFERENCE_GPU generate.py \
```

## 9. 运行测试

```bash
cd ~/HunyuanVideo-1.5-TPU
bash run.sh
```

成功运行后，生成的视频将保存到 `./outputs/output.mp4`。

### 9.1 预期运行结果（8x H100 GPU）

以下是在8x NVIDIA H100 GPU上的实际运行结果：

**总耗时**: 约3分13秒（从模型加载到视频保存）

**生成阶段统计**:
- 模型加载: ~42秒（8个GPU并行加载）
- 主视频生成: ~48秒（50步采样，480p）
- 超分辨率: ~36秒（6步采样，480p→720p）

**生成参数**:
```
提示词: "A girl holding a paper with words "Hello, world!""
宽高比: 16:9
初始分辨率: 848 x 480
最终分辨率: 1280 x 720
视频长度: 121帧
采样步数: 50步 (主) + 6步 (SR)
随机种子: 1
```

**输出文件** (保存在 `./outputs/` 目录):
- `output.mp4` - 最终720p超分辨率视频
- `output_before_sr.mp4` - 原始480p视频
- `output_config.json` - 生成配置文件

**性能指标**:
- 主生成速度: ~1.05 it/s
- SR生成速度: ~5.8 s/step
- 使用Flash Attention 2.8.3
- 启用组卸载和重叠优化

**使用的模型组件**:
- ✅ 主模型 (tencent/HunyuanVideo-1.5)
- ✅ Qwen2.5-VL-7B-Instruct 文本编码器
- ✅ byT5-small 编码器
- ✅ Glyph-SDXL-v2 文本渲染
- ✅ FLUX.1-Redux-dev Vision Encoder
- ✅ 720p超分辨率模型

**注意**: `destroy_process_group()` 警告可以忽略，这是PyTorch分布式训练的常见信息，不影响生成结果。

## 10. 常见问题

### Q1: Flash Attention 导入错误（undefined symbol）

**原因**：Flash Attention 使用了错误的 CUDA 版本编译

**解决方案**：
```bash
pip uninstall -y flash-attn
rm -rf ~/.local/lib/python3.12/site-packages/flash_attn*

# 确保 CUDA 12.9 环境变量正确
export CUDA_HOME=/usr/local/cuda-12.9
export PATH=$CUDA_HOME/bin:$PATH
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH

pip install flash-attn --no-build-isolation --no-cache-dir
```

### Q2: CUDA 版本不匹配

**症状**：PyTorch 报告的 CUDA 版本与系统 CUDA 不同

**检查**：
```bash
# PyTorch 的 CUDA 版本
python -c "import torch; print(torch.version.cuda)"

# 系统 CUDA 版本
nvcc --version
```

两者都应该是 12.9：
- 系统 CUDA：12.9
- PyTorch CUDA：12.9

### Q3: 模型文件下载失败

**解决方案**：
- 使用中国镜像：`HF_ENDPOINT=https://hf-mirror.com`
- 使用 `--resume` 参数继续下载：
  ```bash
  hf download --resume tencent/HunyuanVideo-1.5 --local-dir ./ckpts
  ```

### Q4: GPU 内存不足

**解决方案**：
- 减少 `N_INFERENCE_GPU` 数量
- 降低分辨率：`RESOLUTION=360p`
- 禁用超分辨率：`ENABLE_SR=false`

## 11. 性能优化建议

### 11.1 启用所有加速选项

在 `run.sh` 中：

```bash
CFG_DISTILLED=true      # CFG 蒸馏（2倍加速）
SAGE_ATTN=true          # SageAttention
ENABLE_CACHE=true       # 特征缓存
CACHE_TYPE=deepcache    # 缓存类型
OVERLAP_GROUP_OFFLOADING=true  # 组卸载加速
```

### 11.2 针对 H100 GPU 的配置

```bash
N_INFERENCE_GPU=8       # 使用全部 8 个 GPU
RESOLUTION=720p         # 高分辨率（如果内存足够）
ENABLE_SR=true          # 启用超分辨率
```

## 12. 验证清单

安装完成后，验证以下各项：

- [ ] CUDA 12.9 安装成功：`nvcc --version`
- [ ] PyTorch 2.8.0+cu129 安装成功：`python -c "import torch; print(torch.__version__)"`
- [ ] GPU 可用：`python -c "import torch; print(torch.cuda.is_available())"`
- [ ] Flash Attention 导入成功：`python -c "import flash_attn"`
- [ ] HuggingFace Token 已配置：`echo $HF_TOKEN`
- [ ] 脚本可以运行：`cd ~/HunyuanVideo-1.5-TPU && bash run.sh`

## 附录：环境变量总结

在 `~/.bashrc` 中应包含：

```bash
# CUDA 12.9 环境变量
export CUDA_HOME=/usr/local/cuda-12.9
export PATH=$CUDA_HOME/bin:$PATH
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH

# HuggingFace 配置（必需）
export HF_HOME=/dev/shm/huggingface  # 使用内存文件系统提升性能
export HF_TOKEN=your_huggingface_token_here  # 替换为实际 token

# （可选）中国镜像加速
export HF_ENDPOINT=https://hf-mirror.com
```

每次修改后记得：`source ~/.bashrc`

---

**文档版本**: 4.0
**创建日期**: 2025-12-01
**最后更新**: 2025-12-02
**适用系统**: Ubuntu 24.04 + CUDA 12.9 + PyTorch 2.6.0+

**经验证配置**：
- **Ubuntu 24.04 LTS**
- **CUDA 12.9**
- **PyTorch 2.6.0+cu124** (requirements.txt安装后的版本，满足>=2.6.0要求)
- **torchvision 0.21.0**
- **Flash Attention 2.8.3** (从源码编译)
- **H100/A100 GPU**
- **模型总大小**: 约360GB（包含T2V和I2V所需的所有模型）

**关键经验**：
1. Flash Attention必须强制从源码编译（`FLASH_ATTENTION_FORCE_BUILD=TRUE`）
2. HF_HOME建议设为`/dev/shm/huggingface`以利用内存文件系统
3. 模型下载支持断点续传，可中断后继续
4. Glyph-SDXL-v2仅ModelScope提供，需使用modelscope命令下载
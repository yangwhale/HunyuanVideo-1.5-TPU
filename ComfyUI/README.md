# ComfyUI Usage Guide for HunyuanVideo-1.5

This guide helps you use ComfyUI to run HunyuanVideo-1.5 model.

## 📋 Table of Contents

- [Installation](#installation)
- [Download Models](#download-models)
- [Workflow Templates](#workflow-templates)
- [Links](#links)

## 🚀 Installation

Install ComfyUI from the official repository:

```bash
git clone https://github.com/comfyanonymous/ComfyUI.git
cd ComfyUI
```

For detailed installation instructions, please refer to the [ComfyUI official repository](https://github.com/comfyanonymous/ComfyUI).


## 📥 Download Models

### HunyuanVideo-1.5 Checkpoint

Download the ComfyUI checkpoint from Hugging Face:

**Model**: https://huggingface.co/Comfy-Org/HunyuanVideo_1.5_repackaged

## 🎨 Workflow Templates

Find workflow templates at:

**Templates**: https://github.com/Comfy-Org/workflow_templates/tree/main/templates

### How to Use

1. Download `.json` workflow files from the template repository
2. In ComfyUI, click "Load" and select the workflow file
3. Adjust parameters (prompt, resolution, frames, etc.)
4. Ensure the model path points to the correct checkpoint

### Recommended Inference Configurations

The following table provides the optimal inference configurations (CFG scale, embedded CFG scale, flow shift, and inference steps) for each model to achieve the best generation quality:

| Model | CFG Scale | Embedded CFG Scale | Flow Shift | Inference Steps |
|-------|-----------|-------------------|------------|-----------------|
| 480p T2V | 6 | None | 5 | 50 |
| 480p I2V | 6 | None | 5 | 50 |
| 720p T2V | 6 | None | 9 | 50 |
| 720p I2V | 6 | None | 7 | 50 |
| 480p T2V Distilled | 1 | None | 5 | 50 |
| 480p I2V Distilled | 1 | None | 5 | 50 |
| 720p T2V Distilled | 1 | None | 9 | 50 |
| 720p I2V Distilled | 1 | None | 7 | 50 |
| 720p T2V Distilled Sparse | 1 | None | 7 | 50 |
| 720p I2V Distilled Sparse | 1 | None | 9 | 50 |
| 480→720 SR | 1 | None | 2 | 6 |
| 720→1080 SR | 1 | None | 2 | 8 |

### Prompt Writing Tips

- Use detailed, descriptive prompts for better results
- Refer to the [HunyuanVideo-1.5 Prompt Handbook](https://doc.weixin.qq.com/doc/w3_AXcAcwZSAGgCNACVygLxeQjyn4FYS?scode=AJEAIQdfAAoSfXnTj0AAkA-gaeACk) for guidance
- Include details about camera movement, style, lighting, etc.

## 🔗 Links

- **ComfyUI Repository**: https://github.com/comfyanonymous/ComfyUI
- **HunyuanVideo-1.5 Repository**: https://github.com/Tencent-Hunyuan/HunyuanVideo-1.5
- **Model Checkpoint**: https://huggingface.co/Comfy-Org/HunyuanVideo_1.5_repackaged
- **Workflow Templates**: https://github.com/Comfy-Org/workflow_templates/tree/main/templates
- **Prompt Handbook**: https://doc.weixin.qq.com/doc/w3_AXcAcwZSAGgCNACVygLxeQjyn4FYS?scode=AJEAIQdfAAoSfXnTj0AAkA-gaeACk

---

For issues or questions, please visit the [HunyuanVideo-1.5 repository](https://github.com/Tencent-Hunyuan/HunyuanVideo-1.5) to submit issues or check documentation.

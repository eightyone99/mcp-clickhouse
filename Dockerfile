# 使用 Python 3.11 作为基础镜像
FROM python:3.11-slim-bookworm AS builder

# 安装系统依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 安装 uv
RUN pip install uv

# 设置工作目录
WORKDIR /app

# 复制项目文件
COPY . .

# 同步依赖
RUN uv sync --frozen --no-dev

# 生产阶段
FROM python:3.11-slim-bookworm

# 安装运行时依赖（如果需要）
RUN apt-get update && apt-get install -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /app

# 从构建阶段复制虚拟环境
COPY --from=builder /app/.venv /app/.venv

# 设置 PATH
ENV PATH="/app/.venv/bin:$PATH"

# 暴露端口
EXPOSE 8000

# 启动命令
CMD ["python", "-m", "mcp_clickhouse.main"]
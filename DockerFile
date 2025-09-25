# בסיס עם Chrome+תלויות+Puppeteer בפנים
FROM ghcr.io/puppeteer/puppeteer:latest

# מתקינים Python+pip כדי למשוך mcp-proxy (SSE/HTTP bridge)
USER root
RUN apt-get update && apt-get install -y python3-pip && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir mcp-proxy

# נעתיק את קוד שרת ה-MCP (ה-fork שלך)
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build   # לפי ה-README של הפרויקט

# הגדרות קטנות לכרומיום בסביבה קונטיינרית
ENV XDG_CONFIG_HOME=/tmp/.chromium
ENV XDG_CACHE_HOME=/tmp/.chromium

# Render יזריק PORT; נקשיב עליו
ENV PORT=8080
EXPOSE 8080

# מריצים את גשר ה-SSE/HTTP שפותח פורט ומריץ את שרת ה-MCP stdio
CMD ["mcp-proxy","--host","0.0.0.0","--port","8080","--","node","dist/index.js","--user-data-dir","/tmp/puppeteer-user-data"]

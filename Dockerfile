# Image בסיסי עם Puppeteer + Chromium
FROM ghcr.io/puppeteer/puppeteer:latest

USER root
WORKDIR /app

# התקנת תלויות פרויקט
COPY package*.json ./
RUN npm ci || npm install

# נעתיק את כל הקבצים (כולל bridge.js)
COPY . .

# אם יש TypeScript – ננסה לבנות; אם אין, נמשיך הלאה
RUN npm run build || true

# קונפיג ל-Chromium בתוך קונטיינר
ENV XDG_CONFIG_HOME=/tmp/.chromium
ENV XDG_CACHE_HOME=/tmp/.chromium

# ברירת מחדל – להריץ את MCP דרך node dist/index.js
# אפשר לשנות ל-index.js עם ENV MCP_ARGS=index.js
ENV MCP_CMD=node
ENV MCP_ARGS=dist/index.js

# Render יכניס PORT, נקשיב עליו
ENV PORT=8080
EXPOSE 8080

# הפקודה הסופית: מריצה את bridge.js שמאזין ל-HTTP
CMD ["node","bridge.js"]

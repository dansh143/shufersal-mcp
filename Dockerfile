# Image עם Chromium + Puppeteer מוכן
FROM ghcr.io/puppeteer/puppeteer:latest

# עבודה כ-root כדי להתקין כלים גלובליים
USER root

# תקן locale/permissions קליל (אופציונלי)
ENV XDG_CONFIG_HOME=/tmp/.chromium
ENV XDG_CACHE_HOME=/tmp/.chromium

# התקנות NPM: הפרויקט עצמו + שרת HTTP ל-MC
WORKDIR /app
COPY package*.json ./
RUN npm ci || npm install
COPY . .

# אם יש TypeScript:
RUN npm run build || true   # אל תיפול אם אין תהליך build

# מתקינים גלובלית CLI ל-MCP עם שרת HTTP (ללא pip)
RUN npm install -g @modelcontextprotocol/cli @modelcontextprotocol/server-http

# Render יזריק PORT; נאזין עליו
ENV PORT=8080
EXPOSE 8080

# מפעילים את שרת ה-HTTP של MCP, והוא מריץ את שרת ה-MCP (stdio) כ-child
# שים לב: אם קובץ הכניסה שלך הוא dist/index.js – השאר כמו שהוא;
# אם זה index.js בשורש, החלף ל..."node","index.js"
CMD ["mcp-server-http", "--host", "0.0.0.0", "--port", "8080", "--", "node", "dist/index.js", "--user-data-dir", "/tmp/puppeteer-user-data"]

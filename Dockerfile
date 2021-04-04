FROM openjdk:15-alpine
RUN apk add --update nodejs npm
# Install http-server, concurrently and typescript.
RUN npm install -g http-server
RUN npm install -g concurrently
RUN npm install -g typescript
RUN npm install -g nodemon
# Set working directory.
WORKDIR /usr/games/minecraft
# Copy package.json and package-lock.json for frontend, backend and proxy and install dependencies, before copying the rest. This is more efficient as only changes to these files require a new npm install.
COPY package*.json ./
RUN npm install
COPY backend/package*.json ./backend/
RUN cd backend && npm install
COPY proxy/package*.json ./proxy/
RUN cd proxy && npm install
# Create servers directory to prevent errors.
RUN mkdir servers
# Copy proxy src and compile.
COPY proxy ./proxy/
RUN cd proxy && tsc
# Copy app source.
COPY common ./common/
COPY public ./public/
COPY src ./src/
# Copy compilation config files.
COPY .eslintrc.js babel.config.js tsconfig.json ./
# Build frontend.
RUN npm run build
# Copy backend src and compile.
COPY backend ./backend/
RUN cd backend && tsc

# Add group and user
RUN addgroup -S blockcluster -g 1080 && adduser -S blockcluster -G blockcluster -u 1080
USER blockcluster

EXPOSE 8081
CMD ["npm", "run", "start"]
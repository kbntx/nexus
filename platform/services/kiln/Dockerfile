# syntax=docker/dockerfile:1.26

ARG GO_VERSION
ARG NODE_VERSION
ARG PNPM_VERSION

FROM golang:${GO_VERSION}-alpine AS local-backend

RUN go install github.com/air-verse/air@v1.62.0

WORKDIR /workspace

COPY go.mod go.sum* ./
RUN go mod download

COPY . .

EXPOSE 8080

CMD ["air"]

FROM node:${NODE_VERSION}-alpine AS node-tooling

ARG PNPM_VERSION

ENV PNPM_CONFIG_VERIFY_DEPS_BEFORE_RUN=false
ENV PNPM_CONFIG_TRUST_LOCKFILE=true

RUN npm install -g pnpm@${PNPM_VERSION}

FROM node-tooling AS client-node-modules

WORKDIR /usr/src/app

COPY --parents **/package.json pnpm-workspace.yaml pnpm-lock.yaml .pnpmfile.mjs ./

RUN --mount=type=cache,id=pnpm-store-kiln-client,target=/root/.pnpm-store \
    pnpm_config_store_dir=/root/.pnpm-store pnpm --filter kiln-client deploy /pruned

FROM node-tooling AS local-client

WORKDIR /usr/src/app/platform/services/kiln/client

COPY tsconfig.base.json /usr/src/app/tsconfig.base.json
COPY platform/services/kiln/client .
COPY --from=client-node-modules /pruned/node_modules ./node_modules

EXPOSE 5173

CMD ["pnpm", "dev", "--host", "0.0.0.0"]

FROM node-tooling AS client-builder

WORKDIR /usr/src/app/platform/services/kiln/client

COPY tsconfig.base.json /usr/src/app/tsconfig.base.json
COPY platform/services/kiln/client .
COPY --from=client-node-modules /pruned/node_modules ./node_modules

RUN pnpm build

FROM golang:${GO_VERSION}-alpine AS go-builder

WORKDIR /workspace

COPY platform/services/kiln/server/go.mod platform/services/kiln/server/go.sum* ./
RUN go mod download

COPY platform/services/kiln/server .

RUN CGO_ENABLED=0 go build -o /workspace/bin/kiln ./cmd

FROM gcr.io/distroless/static:nonroot AS prod

WORKDIR /

COPY --from=go-builder /workspace/bin/kiln /kiln
COPY --from=client-builder /usr/src/app/platform/services/kiln/client/dist /client/dist

USER 65532:65532

ENTRYPOINT ["/kiln"]

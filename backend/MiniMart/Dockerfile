# syntax=docker/dockerfile:1
ARG DOTNET_VERSION=8.0

FROM mcr.microsoft.com/dotnet/sdk:${DOTNET_VERSION} AS build
WORKDIR /src

# Restore separately so dependency changes are the only cache invalidator.
COPY ["MiniMart.csproj", "./"]
RUN --mount=type=cache,target=/root/.nuget/packages \
    dotnet restore "MiniMart.csproj"

COPY . .
RUN --mount=type=cache,target=/root/.nuget/packages \
    dotnet publish "MiniMart.csproj" \
      --configuration Release \
      --output /app/publish \
      --no-restore \
      --self-contained false \
      -p:UseAppHost=false \
      -p:PublishTrimmed=false

FROM mcr.microsoft.com/dotnet/aspnet:${DOTNET_VERSION} AS final
WORKDIR /app

# Do not copy .env into the image; provide it at runtime with --env-file.
ENV ASPNETCORE_URLS=http://+:5005 \
    DOTNET_EnableDiagnostics=0 \
    ASPNETCORE_HTTP_PORTS=8080

EXPOSE 5005

COPY --from=build --chown=app:app /app/publish .

USER app

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
  CMD ["dotnet", "MiniMart.dll", "--healthcheck"] || exit 1

ENTRYPOINT ["dotnet", "MiniMart.dll"]
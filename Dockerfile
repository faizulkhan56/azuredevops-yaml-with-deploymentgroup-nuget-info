# ───────────── BUILD & PUBLISH ─────────────
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# 1) Bring in your private-feed config
COPY nuget.config .

# 2) Copy only the web-app csproj and restore against your feed
COPY devopswebapp/devopswebapp.csproj devopswebapp/
RUN dotnet restore devopswebapp/devopswebapp.csproj --configfile nuget.config

# 3) Copy everything else
COPY . .

# 4) Build & publish the web app
RUN dotnet publish devopswebapp/devopswebapp.csproj \
    --configuration Release \
    --no-restore \
    --output /app/publish

# ───────────── RUNTIME IMAGE ─────────────
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# 5) Copy the published bits
COPY --from=build /app/publish .

# 6) Listen on port 80
ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80

# 7) Launch
ENTRYPOINT ["dotnet","devopswebapp.dll"]


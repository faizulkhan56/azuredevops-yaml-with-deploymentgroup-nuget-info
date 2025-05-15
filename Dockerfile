# ───────────── BUILD + TEST ─────────────
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# 1) Copy nuget.config so restore uses your InternalNuGet feed + upstream
COPY nuget.config .

# 2) Copy solution and both project files
COPY devops-webapp-solution.sln .
COPY devopswebapp/devopswebapp.csproj    devopswebapp/
COPY devopswebapp.Tests/devopswebapp.Tests.csproj devopswebapp.Tests/

# 3) Restore all deps
RUN dotnet restore devops-webapp-solution.sln --configfile nuget.config

# 4) Bring in the rest of your source
COPY . .

# 5) Build in Release mode (no need to re-restore)
RUN dotnet build devops-webapp-solution.sln \
    --configuration Release \
    --no-restore

# 6) Run your unit tests (fails the build if any test fails)
RUN dotnet test devopswebapp.Tests/devopswebapp.Tests.csproj \
    --configuration Release \
    --no-build \
    --logger "trx;LogFileName=test_results.trx"

# 7) Publish only the web-app into /app/publish
RUN dotnet publish devopswebapp/devopswebapp.csproj \
    --configuration Release \
    --no-restore \
    --output /app/publish

# ───────────── RUNTIME IMAGE ─────────────
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# 8) Copy the published output
COPY --from=build /app/publish .

# 9) Listen on port 80
ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80

# 10) Launch your app
ENTRYPOINT ["dotnet", "devopswebapp.dll"]


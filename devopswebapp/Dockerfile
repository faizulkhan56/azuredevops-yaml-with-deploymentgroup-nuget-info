# ─────────────── BUILD STAGE ───────────────
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# 1) Copy nuget.config so restore uses your InternalNuGet feed + nuget.org upstream
COPY nuget.config .

# 2) Copy solution and project files
COPY devopswebapp-solution.sln .
COPY devopswebapp/devopswebapp.csproj    devopswebapp/
# (optional) if you want to run tests inside the container:
# COPY devopswebapp.Tests/devopswebapp.Tests.csproj devopswebapp.Tests/

# 3) Restore against your private feed (and its upstream)
RUN dotnet restore devopswebapp-solution.sln --configfile nuget.config

# 4) Copy the rest of the source
COPY . .

# 5) Build the entire solution in Release mode
RUN dotnet build devopswebapp-solution.sln \
    --configuration Release \
    --no-restore

# 6) (Optional) Run your unit tests
# RUN dotnet test devopswebapp.Tests/devopswebapp.Tests.csproj \
#     --configuration Release --no-build \
#     --logger "trx;LogFileName=test_results.trx"

# 7) Publish only the web-app project into /app/publish
RUN dotnet publish devopswebapp/devopswebapp.csproj \
    --configuration Release \
    --no-restore \
    --output /app/publish

# ───────────── RUNTIME STAGE ─────────────
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# 8) Copy the published output from the build stage
COPY --from=build /app/publish .

# 9) Configure ASP.NET Core to listen on port 80
ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80

# 10) Launch the app
ENTRYPOINT ["dotnet", "devopswebapp.dll"]


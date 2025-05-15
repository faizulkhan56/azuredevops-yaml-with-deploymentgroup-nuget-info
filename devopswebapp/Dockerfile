# ───────────── BUILD ─────────────
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Pull in nuget.config if you have one
COPY nuget.config .

# Copy your .sln and project(s)
COPY *.sln .  
COPY devopswebapp/*.csproj devopswebapp/

# Restore using your config
RUN dotnet restore devopswebapp.sln --configfile nuget.config

# Copy the rest of the code
COPY . .

# Build & test & publish
RUN dotnet build devopswebapp.sln -c Release
RUN dotnet test devopswebapp.Tests/devopswebapp.Tests.csproj -c Release --no-build
RUN dotnet publish devopswebapp/devopswebapp.csproj -c Release -o /app/publish

# ───────────── RUNTIME ─────────────
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .

ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80

ENTRYPOINT ["dotnet","devopswebapp.dll"]


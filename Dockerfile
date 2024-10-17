# Image de base pour l'exécution
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 5000

# Configuration de l'URL pour l'application
ENV ASPNETCORE_URLS=http://+:5000

# Utilisation d'un utilisateur non-root pour plus de sécurité
USER app

# Image pour la compilation
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG configuration=Release
WORKDIR /src

# Copie du fichier projet et restauration des dépendances
COPY ["APL2003.csproj", "./"]
RUN dotnet restore "APL2003.csproj"

# Copie de tous les fichiers source
COPY . .

# Compilation du projet
RUN dotnet build "APL2003.csproj" -c $configuration -o /app/build

# Publication de l'application
FROM build AS publish
ARG configuration=Release
RUN dotnet publish "APL2003.csproj" -c $configuration -o /app/publish /p:UseAppHost=false

# Image finale
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "APL2003.dll"]

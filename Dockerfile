# (Keep your "base" stage as is)
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080

# === REPLACE THE BUILD STAGE WITH THIS ===
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy solution and project files
COPY ["MyApi.sln", "global.json", "./"]
COPY ["MyApi/MyApi.csproj", "MyApi/"]

# Restore dependencies separately for better caching
RUN dotnet restore "MyApi.sln"

# Copy the rest of the application source code into the correct sub-directory
COPY . .
RUN ls -R /src
# Publish the project
WORKDIR "/src/MyApi"
RUN dotnet publish "MyApi.csproj" -c Release -o /app/publish --no-restore

# === KEEP THE "final" STAGE AS IS ===
FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "MyApi.dll"]
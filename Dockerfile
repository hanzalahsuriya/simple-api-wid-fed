FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# copy solution and restore as distinct layers
COPY MyApi/global.json ./
COPY MyApi/MyApi.sln ./
COPY MyApi/MyApi/*.csproj MyApi/
RUN dotnet restore "./MyApi.sln"

# copy everything else and publish
COPY MyApi/. ./
WORKDIR /src/MyApi
RUN dotnet publish "MyApi.csproj" -c Release -o /app/publish --no-restore

FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "MyApi.dll"]

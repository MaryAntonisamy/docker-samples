
# Use the official .NET 8 SDK image from Microsoft
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80

# SDK image to build the source
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy and restore the API project
COPY ["MyApi/MyApi.csproj", "MyApi/"]
RUN dotnet restore "MyApi/MyApi.csproj"

# Copy and restore the Worker project
COPY ["MyWorker/MyWorker.csproj", "MyWorker/"]
RUN dotnet restore "MyWorker/MyWorker.csproj"

# Copy everything else and build
COPY . .
WORKDIR "/src/MyApi"
RUN dotnet build "MyApi.csproj" -c Release -o /app/build

WORKDIR "/src/MyWorker"
RUN dotnet build "MyWorker.csproj" -c Release -o /app/build

FROM build AS publish
WORKDIR "/src/MyApi"
RUN dotnet publish "MyApi.csproj" -c Release -o /app/publish
WORKDIR "/src/MyWorker"
RUN dotnet publish "MyWorker.csproj" -c Release -o /app/publish

# Final stage/image
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "MyApi.dll"] # Assuming the API will be the primary process

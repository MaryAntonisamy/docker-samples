# Base Image for building .NET applications
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj files and restore as distinct layers
COPY ["MyApi/MyApi.csproj", "MyApi/"]
COPY ["MyWorker/MyWorker.csproj", "MyWorker/"]
RUN dotnet restore "MyApi/MyApi.csproj"
RUN dotnet restore "MyWorker/MyWorker.csproj"

# Copy everything else and build
COPY . .
RUN dotnet publish "MyApi/MyApi.csproj" -c Release -o /app/api
RUN dotnet publish "MyWorker/MyWorker.csproj" -c Release -o /app/worker

# Build the runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
EXPOSE 80

# Install Supervisor
RUN apt-get update && apt-get install -y supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy build outputs to app folder
COPY --from=build /app/api ./api
COPY --from=build /app/worker ./worker

# Start Supervisor to manage multiple services
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

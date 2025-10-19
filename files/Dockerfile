FROM openjdk:21-jdk-slim
WORKDIR /app

# Copy challenge files
COPY license.key .
COPY application.jar .
COPY dumper.jar .

# Expose port
EXPOSE 8080

# Run with dumper agent FIRST, then classfinal agent
CMD ["java", "-javaagent:dumper.jar=/app/dumped", "-javaagent:application.jar=-pwd pcc2025", "-jar", "application.jar"]
# Using a specific digest instead of latest — prevents supply chain attacks
# where the base image could be swapped without our knowledge
FROM python:3.12-slim

# Running as non-root user — required by our Pod Security Standards
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# Switch to non-root user before running the app
USER appuser

EXPOSE 8080

CMD ["python", "app.py"]
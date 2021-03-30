helm install sdk -f ./helm/values.yaml  ./helm \
--namespace=default \
--set nameOverride=blotout \
--set image.repository=satish \
--set image.tag=1 \
--set image.imagePullSecrets[0].name=regcred \
--set autoscaling.enabled=true \
--set autoscaling.minReplicas=1 \
--set autoscaling.maxReplicas=2 \
--set autoscaling.targetCPUUtilizationPercentage=50 \
--set autoscaling.targetMemoryUtilizationPercentage=50 \
--set readinessProbe.path=/api/v1/health \
--set livenessProbe.path=/api/v1/health \
--set ingress.enabled=true \
--set ingress.hosts[0]=app.blotout.io \
--dry-run --debug
# GUION TECH TALK - INFRACOST
## Gestión de Costos en Infraestructura como Código

---

## 1. INTRODUCCIÓN

### ¿Qué es Infracost?
- Herramienta open-source para calcular costos de infraestructura ANTES de desplegarla
- Evita sorpresas en la factura a fin de mes
- Compatible con Terraform, Terragrunt, y otros IaC tools
- Más de 5M de descargas, comunidad muy activa

### ¿Por qué es importante?
- Visibilidad de costos en tiempo de desarrollo
- FinOps: cultura de optimización de costos cloud
- Prevención de costos inesperados
- Documentación automática de costos

### Links importantes:
- GitHub: https://github.com/infracost/infracost
- Documentación: https://www.infracost.io/docs/
- Dashboard: https://dashboard.infracost.io

---

## 2. INSTALACIÓN
### Linux/WSL:
```bash
curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh
```

### macOS (con Homebrew):
```bash
brew install infracost
```

### Verificar instalación:
```bash
infracost --version
```

**Mostrar en terminal:** Salida de la versión instalada

---

## 3. AUTENTICACIÓN

### Paso 1: Login
```bash
infracost auth login
```

**Qué pasa:**
- Se abre el navegador (o te da una URL)
- Creas cuenta gratuita (con GitHub/Google/email)
- API key se guarda automáticamente en `~/.config/infracost/credentials.yml`

### Verificar autenticación:
```bash
cat ~/.config/infracost/credentials.yml
```

**Nota:** La cuenta gratuita incluye:
- CLI ilimitado
- Dashboard básico
- Comentarios en PRs
- Hasta 500 recursos

---

## 4. USO BÁSICO - CLI

### Estructura del proyecto de demo:
```
tech-talk-terraform/
├── prueba_1/
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars
```

### Comando básico: Breakdown
```bash
cd /ruta/a/tu/proyecto
infracost breakdown --path=.
```

**Mostrar:** Tabla con desglose completo de recursos y costos mensuales

**Explicar la salida:**
- Cada recurso con su costo mensual
- Desglose por componente (CPU, storage, networking)
- "Usage costs" (dependen del uso real)
- Total mensual estimado

### Ejemplo de output:
```
Project: prueba_1

 Name                                                   Monthly Qty  Unit     Monthly Cost   
                                                                                             
 google_compute_instance.demo_vm["e2-standard-4"]                                           
 ├─ Instance usage (on-demand, e2-standard-4)                730  hours          $97.84   
 └─ Standard provisioned storage (pd-standard)                50  GB              $2.00   
                                                                                             
 google_sql_database_instance.demo_db["demo-mysql"]                                         
 └─ SQL instance (db-g1-small, zonal)                        730  hours          $23.00   

 OVERALL TOTAL                                                                    $551.30
```

### Variaciones útiles:

#### Formato JSON (para integración):
```bash
infracost breakdown --path=. --format=json > infracost.json
```

#### Formato HTML (para reportes):
```bash
infracost breakdown --path=. --format html > infracost-report.html
```

#### Ver solo el total:
```bash
infracost breakdown --path=. --format=json | jq -r '.totalMonthlyCost'
```

---

## 5. INFRACOST DIFF - Comparar cambios

**Escenario:** "Voy a cambiar una VM de e2-medium a e2-standard-4, ¿cuánto me costará?"

### Paso 1: Guardar baseline
```bash
infracost breakdown --path=. --format=json --out-file=baseline.json
```

### Paso 2: Hacer cambios en terraform.tfvars
```hcl
# Cambiar:
machine_type = ["e2-medium"]

# Por:
machine_type = ["e2-standard-4"]
```

### Paso 3: Ver diferencia
```bash
infracost diff --path=. --compare-to=baseline.json
```

**Mostrar:** Output con:
- ❌ Recursos eliminados
- ✅ Recursos nuevos
- ~ Recursos modificados
- 💰 Diferencia de costos (+$XX o -$XX)

### Ejemplo de output:
```
~ google_compute_instance.demo_vm
  +$73 ($24 → $97)

    ~ Instance usage (e2-medium → e2-standard-4)
      +$73 ($24 → $97)

Monthly cost change: +$73 ($551 → $624)
Percent: +13%
```

---

## 6. DASHBOARD DE INFRACOST CLOUD

**URL:** https://dashboard.infracost.io

### Subir datos al dashboard:
```bash
infracost breakdown --path=. --format=json > infracost.json
infracost upload --path=infracost.json
```

### Qué puedes ver en el dashboard:

**1. Projects Overview**
- Lista de todos tus proyectos
- Costos totales por proyecto
- Última actualización

**2. Cost Estimates**
- Desglose detallado de recursos
- Histórico de cambios de costos
- Gráficos de tendencias

**3. Pull Request History**
- Todos los PRs analizados
- Cambios de costos por PR
- Estado de aprobación/rechazo

**4. Policies (Governance)**
- Políticas de FinOps activas
- Validación de tags obligatorios
- Compliance con Well-Architected Framework
- Alertas de incrementos de costos

**5. Organization Settings**
- Configuración de tags obligatorios
- Umbrales de alerta (ej: >$100/mes)
- Integraciones (GitHub, GitLab, etc.)

**Demostrar en vivo:**
- Navegar por el dashboard
- Mostrar un proyecto
- Ver histórico de costos
- Mostrar políticas activas

---

## 7. INTEGRACIÓN CON PULL REQUESTS

### Configuración: GitHub App (Recomendado)

#### Paso 1: Conectar repositorio
1. Ve a: https://dashboard.infracost.io/integrations
2. Click en "Connect GitHub"
3. Autoriza la app
4. Selecciona el repositorio `tech-talk-terraform`

#### Paso 2: Guardar API Key como secret
1. Ve a: `https://github.com/TU_USUARIO/tech-talk-terraform/settings/secrets/actions`
2. Click "New repository secret"
3. Name: `INFRACOST_API_KEY`
4. Value: Tu API key (de `~/.config/infracost/credentials.yml`)
5. Click "Add secret"

**¡Y listo!** Ahora cada PR tendrá comentarios automáticos

### Demo en vivo: Crear un PR

#### Crear rama y hacer cambio:
```bash
cd /ruta/a/tu/proyecto
git checkout -b demo-cost-increase

# Editar terraform.tfvars - cambiar tier de DB
# De: tier = "db-f1-micro"
# A:  tier = "db-g1-small"

git add .
git commit -m "feat: upgrade MySQL for better performance"
git push -u origin demo-cost-increase
```

#### Crear PR desde GitHub:
```bash
# URL automática que aparece después del push
# O ir a: https://github.com/TU_USUARIO/tech-talk-terraform/pulls
```

**Mostrar en el PR:**

El bot de Infracost comentará automáticamente con:

```
💰 Infracost report

Monthly estimate increased by $16 📈

Changed project: +$16 (+8%)

~ google_sql_database_instance.demo_db["demo-mysql"]
  +$16 ($7 → $23)

    ~ SQL instance (db-f1-micro → db-g1-small)
      +$16 ($7 → $23)
```

**Destacar:**
- ✅ Comentario automático en cada PR
- ✅ Actualización en tiempo real con nuevos commits
- ✅ Comparación antes/después
- ✅ Desglose por recurso modificado
- ✅ Políticas de FinOps (si están activas)

---

## 8. POLÍTICAS DE FINOPS

### ¿Qué son las políticas?

Reglas automáticas que validan:
- **Tags obligatorios** (Environment, Service, CostCenter)
- **Umbrales de costo** (máx $X por recurso)
- **Mejores prácticas** (no usar recursos deprecated)
- **Compliance** (Well-Architected Framework)

### Ejemplo: Tag policy

**Si falta un tag obligatorio:**
```
🔴 FinOps tags

resource google_sql_database_instance.demo_db["demo-mysql"]

Missing mandatory tag: Environment
Missing mandatory tag: Service
```

**Solución en Terraform:**
```hcl
resource "google_sql_database_instance" "demo_db" {
  # ... configuración ...
  
  settings {
    tier = "db-g1-small"
    
    user_labels = {
      environment = "dev"
      service     = "demo-database"
    }
  }
}
```

**Después:**
```
✅ This pull request is aligned with your company's FinOps policies
```

---

## 9. EXTENSIÓN DE VS CODE

### Instalación:
1. Abrir VS Code
2. Ir a Extensions (Ctrl+Shift+X)
3. Buscar "Infracost"
4. Click "Install"

**Link:** https://marketplace.visualstudio.com/items?itemName=Infracost.infracost

### Funcionalidades:

**1. Code Lens**
- Muestra costos arriba de cada recurso
- Ejemplo: `💰 $97.84/mo`

**2. Hover Tooltips**
- Pasa el cursor sobre un recurso
- Ver desglose detallado de costos

**3. Panel lateral**
- Vista completa del proyecto
- Costos totales y por recurso

**4. Actualización en tiempo real**
- Los costos se recalculan al guardar

### Generar breakdown para la extensión:
```bash
cd prueba_1
infracost breakdown --path=. --format=json --out-file=.infracost-breakdown.json
```

Luego recargar VS Code: `Ctrl+Shift+P` → "Reload Window"

**Nota:** La extensión puede tener problemas con WSL. En ese caso, mencionar que es un issue conocido y que lo más importante (CLI + Dashboard + PRs) funciona perfectamente.

---

## 10. CASOS DE USO REALES

### 1. Antes de hacer terraform apply
```bash
terraform plan
infracost breakdown --path=.
# Revisar costos antes de aplicar
terraform apply
```

### 2. Comparar dos configuraciones
```bash
# Opción A: e2-medium con 20GB
infracost breakdown --path=./config-a --format=json > a.json

# Opción B: e2-standard-4 con 50GB
infracost breakdown --path=./config-b --format=json > b.json

# Comparar
infracost diff --path=b.json --compare-to=a.json
```

### 3. CI/CD Pipeline
```yaml
# .github/workflows/infracost.yml
- name: Run Infracost
  run: infracost breakdown --path=.
  
- name: Check cost threshold
  run: |
    COST=$(infracost breakdown --path=. --format=json | jq '.totalMonthlyCost')
    if (( $(echo "$COST > 1000" | bc -l) )); then
      echo "Cost exceeds $1000/month!"
      exit 1
    fi
```

### 4. Documentación automática
```bash
# Generar report HTML
infracost breakdown --path=. --format html > docs/cost-estimate.html

# Incluir en README
echo "## Cost Estimate" >> README.md
echo "Monthly cost: \$$(infracost breakdown --path=. --format=json | jq -r '.totalMonthlyCost')" >> README.md
```

---

## 11. MEJORES PRÁCTICAS (2-3 min)

### ✅ DO's:

1. **Ejecutar en cada PR**
   - Siempre revisar impacto en costos antes de mergear

2. **Configurar políticas de tags**
   - Facilita tracking de costos por proyecto/ambiente

3. **Establecer umbrales de alerta**
   - Ej: alertar si un PR incrementa costos >10%

4. **Usar infracost diff**
   - No solo ver costos totales, sino cambios

5. **Documentar decisiones de costo**
   - "Elegimos e2-standard-4 porque [razón] (costo: $97/mes)"

### ❌ DON'Ts:

1. **No ignorar los warnings**
   - Si Infracost alerta, investigar

2. **No hacer apply sin revisar costos**
   - Siempre `infracost breakdown` antes de `terraform apply`

3. **No depender solo del free tier**
   - Calcular costos reales para producción

4. **No olvidar usage costs**
   - Storage, transferencia de datos, etc. dependen del uso

---

## 12. RECURSOS Y LINKS (1 min)

### Documentación oficial:
- Docs: https://www.infracost.io/docs/
- Ejemplos: https://github.com/infracost/infracost/tree/master/examples
- Cloud Pricing API: https://www.infracost.io/pricing/

### Integraciones:
- GitHub Actions: https://www.infracost.io/docs/integrations/github_actions/
- GitLab CI: https://www.infracost.io/docs/integrations/gitlab_ci/
- Atlantis: https://www.infracost.io/docs/integrations/atlantis/
- VS Code Extension: https://marketplace.visualstudio.com/items?itemName=Infracost.infracost

### Comunidad:
- GitHub Discussions: https://github.com/infracost/infracost/discussions
- Slack Community: https://www.infracost.io/community-chat
- Twitter: @infracost

---

## 13. RESUMEN Y CONCLUSIÓN

### Lo que hemos visto:

✅ **CLI potente**: `infracost breakdown`, `infracost diff`
✅ **Dashboard visual**: Histórico, tendencias, governance
✅ **Automatización**: Comentarios en PRs, CI/CD
✅ **Extensión VS Code**: Costos en tiempo real
✅ **FinOps**: Políticas, tags, compliance

### Valor para el equipo:

- **Visibilidad**: Saber cuánto cuesta ANTES de desplegar
- **Prevención**: Evitar sorpresas en facturación
- **Optimización**: Identificar oportunidades de ahorro
- **Governance**: Cumplir políticas corporativas

### Call to Action:

1. Instalar Infracost hoy mismo
2. Integrar en su flujo de trabajo actual
3. Configurar políticas según necesidades
4. Educar al equipo sobre costos cloud

**¡Preguntas?**

---

## COMANDOS DE REFERENCIA RÁPIDA

```bash
# Instalación
curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh

# Autenticación
infracost auth login

# Ver costos actuales
infracost breakdown --path=.

# Ver diferencia con baseline
infracost diff --path=. --compare-to=baseline.json

# Generar JSON
infracost breakdown --path=. --format=json > infracost.json

# Generar HTML report
infracost breakdown --path=. --format html > report.html

# Subir al dashboard
infracost upload --path=infracost.json

# Ver ayuda
infracost --help
infracost breakdown --help
```

---

## DEMO PRÁCTICA PASO A PASO

### Setup inicial (hacer antes de la presentación):
```bash
# 1. Verificar instalación
infracost --version

# 2. Verificar autenticación
infracost auth login

# 3. Verificar proyecto configurado en GCP
gcloud config get-value project

# 4. Preparar estructura
cd ~/Devoteam/tech-talk-terraform/prueba_1
ls -la
```

### Durante la presentación:

#### Demo 1: Breakdown básico
```bash
cd ~/Devoteam/tech-talk-terraform/prueba_1
infracost breakdown --path=.
```

#### Demo 2: Diferentes formatos
```bash
# JSON
infracost breakdown --path=. --format=json > infracost.json
cat infracost.json | jq '.totalMonthlyCost'

# HTML
infracost breakdown --path=. --format html > infracost-report.html
# Abrir el archivo HTML en el navegador
```

#### Demo 3: Infracost diff
```bash
# Guardar baseline
infracost breakdown --path=. --format=json --out-file=baseline.json

# Hacer un cambio (editar terraform.tfvars)
# Cambiar: machine_type = ["e2-standard-4"]
# Por: machine_type = ["e2-standard-4", "e2-standard-8"]

# Ver diferencia
infracost diff --path=. --compare-to=baseline.json
```

#### Demo 4: Upload al dashboard
```bash
infracost breakdown --path=. --format=json > infracost.json
infracost upload --path=infracost.json

# Abrir dashboard
# https://dashboard.infracost.io
```

#### Demo 5: PR con Infracost
```bash
# Crear rama nueva
git checkout -b demo-tech-talk

# Hacer cambio significativo en terraform.tfvars
# Ej: Cambiar tier de DB a uno más caro

git add .
git commit -m "demo: upgrade database tier"
git push -u origin demo-tech-talk

# Ir a GitHub y crear PR
# Mostrar comentario automático de Infracost
```

---

## TROUBLESHOOTING

### Problema: "Infracost no encuentra credenciales"
```bash
# Verificar archivo de credenciales
cat ~/.config/infracost/credentials.yml

# Si no existe, volver a hacer login
infracost auth login
```

### Problema: "Error al analizar recursos GCP"
```bash
# Verificar que gcloud está configurado
gcloud config list

# Verificar proyecto
gcloud config get-value project

# Configurar proyecto correcto
gcloud config set project thomas-alberto-sandbox1
```

### Problema: "Extension de VS Code no muestra costos"
```bash
# Generar breakdown local
cd prueba_1
infracost breakdown --path=. --format=json --out-file=.infracost-breakdown.json

# Recargar VS Code
# Ctrl+Shift+P → "Reload Window"
```

### Problema: "Dashboard no muestra datos"
```bash
# Verificar que se subió correctamente
infracost upload --path=infracost.json

# Verificar que estás en la org correcta en el dashboard
# https://dashboard.infracost.io
```

---

**FIN DEL GUION**

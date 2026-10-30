# 📱 Cómo compilar tu APK con GitHub Actions y publicarlo en Appetize.io (Sin tener Flutter instalado)

> Con este método **NO necesitas tener Flutter instalado en tu computadora**. 
> GitHub Actions compilará automáticamente el APK en los servidores de GitHub en la nube (Ubuntu). Tú solo tendrás que descargar el archivo `.apk` y subirlo a Appetize.io en un par de clics.

---

## ⚡ Resumen del Flujo de Trabajo

```
   1. Subes tu código a GitHub (git push)
                 ↓
   2. GitHub Actions compila el APK en la nube (~2-3 minutos)
                 ↓
   3. Descargas el APK desde la pestaña "Actions" o "Releases"
                 ↓
   4. Subes el APK a Appetize.io
                 ↓
   5. Obtienes tu enlace público y lo pegas en el README.md
```

---

## Paso 1 — Subir los cambios a GitHub para activar GitHub Actions

Ya dejamos configurado el archivo `.github/workflows/build-apk.yml`. Este archivo se activa automáticamente cada vez que haces `push` a la rama `DMI-Practica05` o `main`, o manualmente desde la web de GitHub.

Abre tu terminal en la raíz de tu repositorio y ejecuta:

```bash
git add .
git commit -m "feat(ci): configurar build automatico de APK de Widgets App con GitHub Actions"
git push origin DMI-Practica05
```

*(Si trabajas en la rama `main`, cámbialo por `git push origin main`)*.

---

## Paso 2 — Ver la compilación en GitHub Actions y descargar el APK

1. Abre tu repositorio en GitHub desde el navegador:  
   `https://github.com/TU-USUARIO/Practicas-DMI-230040`
2. Haz clic en la pestaña superior **"Actions"** (con el ícono de play ▶️).
3. En el menú izquierdo verás el flujo llamado: **"Build Widgets App APK"**.
4. Verás una ejecución en curso con un círculo amarillo girando 🟡 (dice algo como *"feat(ci): configurar build..."*).
   > *Nota:* Si por alguna razón no inició solo, haz clic en **"Build Widgets App APK"** a la izquierda, presiona el botón gris **"Run workflow"** a la derecha y luego el botón verde **"Run workflow"**.
5. Espera unos **2 a 3 minutos** mientras GitHub instala Flutter y compila el APK en la nube.
6. Cuando termine, el círculo cambiará a una marca de verificación verde **✔️**.
7. Haz clic sobre el nombre de esa ejecución.
8. Baja hasta la sección **Artifacts** (al final de la página):
   - Verás un archivo llamado: `WidgetsApp-release-apk`
   - Haz clic sobre él para descargarlo.
   - Se descargará un archivo `.zip` a tu computadora.
   - Descomprímelo y dentro tendrás: **`app-release.apk`**.

*(Además, si tienes permisos de Release, también se publicará automáticamente en la sección **Releases** de tu repositorio con el tag `v1.0.0-widgets-app`)*.

---

## Paso 3 — Crear cuenta o Iniciar Sesión en Appetize.io

1. Ve a [https://appetize.io](https://appetize.io) en tu navegador.
2. Si ya tienes cuenta, haz clic en **Log in**. Si no, haz clic en **"Get Started for Free"** y regístrate con tu correo o cuenta de Google.
3. Confirma tu correo si te lo solicita.

> [!NOTE]
> La cuenta gratuita incluye **100 minutos al mes** de emulación en el navegador, más que suficiente para calificar la práctica.

---

## Paso 4 — Subir el APK a Appetize.io

1. En tu panel de Appetize, haz clic en el botón **"Upload"** o **"+ New App"** (esquina superior derecha).
2. En la pantalla que aparece:
   - **File:** Arrastra el archivo `app-release.apk` que descomprimiste en el Paso 2 (o da clic en *Choose file*).
   - **Platform:** Selecciona **Android**.
   - **App Name / Note (opcional):** Escribe `Widgets App - DMI 230040`.
3. Haz clic en el botón azul **"Upload"** o **"Next"**.
4. Espera unos 15-30 segundos mientras Appetize procesa tu APK.

---

## Paso 5 — Obtener tu Enlace Público de Demostración

1. Al finalizar la subida, verás un simulador con tu aplicación ya funcionando en la pantalla.
2. En la parte derecha o en la configuración de la app verás un apartado que dice **"App URL"** o **"Public Link"**, similar a este formato:
   ```text
   https://appetize.io/app/a1b2c3d4e5f6g7h8i9j0k1l2m3?device=pixel7&osVersion=13.0
   ```
3. Copia ese enlace.
4. **Prueba rápida:** Abre una ventana de incógnito en tu navegador, pega el enlace y presiona "Tap to Play" para comprobar que cualquier persona pueda probar tu app sin iniciar sesión.

---

## Paso 6 — Agregar el Enlace a tu README.md

Abre el archivo `Practica 5/widgets_app/README.md` y en la sección correspondiente agrega tu enlace de Appetize:

```markdown
## 🚀 Demostración en Línea (Appetize.io)

Puedes interactuar con la aplicación directamente desde tu navegador sin instalar nada:

👉 [**Probar Widgets App en Appetize.io →**](https://appetize.io/app/PEGA_AQUI_TU_ENLACE_DE_APPETIZE)
```

---

## Paso 7 — Publicar el Diagrama en GitHub Pages (También 100% Automático)

Ya dejamos actualizado `.github/workflows/pages.yml`. Para que GitHub Pages publique tu diagrama interactivo:

1. Ve a tu repositorio en GitHub.
2. Entra a **Settings** ⚙️ (arriba a la derecha).
3. En el menú lateral izquierdo, haz clic en **Pages**.
4. En **Build and deployment**:
   - En **Source**, asegúrate de que esté seleccionado: **"GitHub Actions"**.
5. Cada vez que hagas `git push` a `DMI-Practica05` o `main`, el workflow desplegará tu diagrama automáticamente.
6. Tu diagrama estará disponible públicamente en:
   ```text
   https://TU-USUARIO.github.io/Practicas-DMI-230040/Practica-05/widgets_app/architecture-diagram.html
   ```
   *(o también con espacios codificados `%20`)*:
   ```text
   https://TU-USUARIO.github.io/Practicas-DMI-230040/Practica%205/widgets_app/architecture-diagram.html
   ```

---

## 📋 Lista de Verificación (Checklist)

- [ ] `git push` realizado a GitHub.
- [ ] Ejecución de GitHub Actions completada en verde (✔️).
- [ ] Archivo `WidgetsApp-release-apk.zip` descargado y descomprimido (`app-release.apk`).
- [ ] APK subido a Appetize.io.
- [ ] Enlace público de Appetize probado en pestaña de incógnito.
- [ ] Enlace de Appetize pegado en `README.md`.
- [ ] Enlace de GitHub Pages del diagrama interactivo actualizado con tu usuario real en `README.md`.

# PlayHub theme for Pegasus

- Este tema sigue siendo una interfaz minimalista y centrada, diseñada para ofrecer una experiencia de navegación fluida. Aunque conserva su esencia sencilla, ahora incorpora algunos efectos visuales y sonoros que enriquecen la interacción sin comprometer la limpieza del diseño. La principal característica visual sigue siendo la portada del juego (boxFront), destacada como el elemento gráfico principal. La navegación es intuitiva, permitiendo un desplazamiento fácil entre las colecciones y los juegos, acompañado de efectos sutiles al moverse entre colecciones, seleccionar juegos o marcar un juego como favorito.

- Incluye dos colecciones adicionales: "FAVORITE" y "HISTORY". La colección "FAVORITE" agrupa todos los juegos marcados como favoritos por el usuario, mientras que "HISTORY" se encarga de mostrar los juegos lanzados recientemente. ~~Esta última colección contiene solo aquellos juegos que han sido jugados por más de un minuto en los últimos siete días.~~

- En la parte inferior de la pantalla, una barra de información muestra la cantidad de juegos en la colección actual, junto con la fecha y hora actuales. Para obtener más información sobre un juego, presione el botón superior para ver detalles adicionales.

![VIEW](https://github.com/ZagonAb/PlayHub/blob/ddd137a33fa0b96422846553522bfb406102eeea/.meta/screenshots/view.gif)

# Screenshots

![screenshots0](https://github.com/ZagonAb/PlayHub/blob/d9ec1e0567b81f206d75f3239952b42dd723b344/.meta/screenshots/screenshot1.png)
![screenshots1](https://github.com/ZagonAb/PlayHub/blob/d9ec1e0567b81f206d75f3239952b42dd723b344/.meta/screenshots/screenshot2.png)

 <details>
<summary>Cambios y mejoras recientes en el Tema desde 12/24</summary> 
  <br>
  
<details>
<summary>Mejoras en reloj</summary>

- Se implementó una corrección en la actualización de la hora. Ahora el reloj se actualiza correctamente cada segundo mediante un Timer.
</details>

<details>
<summary>Personalización de la Apariencia: Selección de Temas de Colores</summary>

- Se ha implementado un sencillo menú para la selección de cuatro tipos distintos de temas de color: **WHITE AND BLACK** (el tema predeterminado), **DARK BREEZE**, **BREEZE** y **NORDIC DARKER**. Esta implementación se basa en los colores principales de **KDE Neon** y del tema **NORDIC DARKER** Además, utilizando api.memory, la interfaz guardará y restaurará el tema seleccionado al volver a abrirla."
</details>

<details>
<summary>Experiencia Mejorada: Animaciones y Nuevos Efectos de Sonido</summary>

- Los efectos de sonido han sido renovados, y se ha añadido una animación especial para el lanzamiento del juego seleccionado.
</details>

<details>
<summary>Vista de detalles mejorada</summary>

- Nueva función al presionar "Y" en el gamepad: una vista de detalles se deslizará desde la parte inferior, revelando datos del juego, tales como el título, la calificación, la última vez jugado, el desarrollador, el editor, el género, el año de lanzamiento y el tiempo de juego (oculto si es igual a 0).
- Cada tema cuenta con su propio overlay para mostrar los detalles del juego, utilizando una captura de pantalla del juego para una vista rápida.
</details>

<details>
<summary>Secuencia de apertura mejorada</summary>

-  Se agregaron animaciones de entrada coordinadas que presentan una transición de zoom suave y una revelación dinámica letra por letra de "PlayHub", lo que crea una experiencia de inicio atractiva.
</details>

<details>
<summary>Descripción añadida</summary>

- Se agregó un nuevo componente de texto de desplazamiento dinámico para mostrar la descripción del juego.
- Muestra el texto de la descripción del juego hasta el segundo punto seguido, utilizando una animación de desplazamiento suave si es necesario. 
- Maneja las descripciones faltantes con un mensaje de respaldo.
![descr](https://github.com/ZagonAb/PlayHub/blob/f67a27830033c2da68182b7f2d0e8d10b86027ad/.meta/screenshots/descr.gif)
</details>

<details>
<summary>Actualización del Sistema de Visualización de Juegos</summary>

- Se ha implementado una visualización adaptativa que se activa al seleccionar la colección "History".
- Para esta colección, se utiliza un diseño en formato grid de 3x2, empleando capturas de pantalla como elemento gráfico principal.
- Esto se ha realizado con la intención de distinguir la colección "History" de las demás y hacerla más única y agradable de ver.

![history](https://github.com/ZagonAb/PlayHub/blob/65e0eb15dc834c097ab1b59da58690a43ab328f7/.meta/screenshots/history.png)
</details>

<details>
<summary>Optimización de animaciones y eliminación de loader</summary>

- Se eliminó el loader y se simplificó la animación de container en gameInfo para mejorar la experiencia del usuario.

</details>

</details>
 
# Licencia
<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Licencia Creative Commons" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a><br /><a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"></a>

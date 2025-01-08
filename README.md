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

- Se ha implementado un sencillo menú para la selección de cuatro tipos distintos de temas de color: **WHITE AND BLACK** (el tema predeterminado), **DARK BREEZE**, **BREEZE** y **NORDIC DARKER**. Esta implementación se basa en los colores principales de **KDE Neon** del tema **NORDIC DARKER** Además, utilizando api.memory, la interfaz guardará y restaurará el tema seleccionado al volver a abrirla."
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

![screenshots3](https://github.com/ZagonAb/PlayHub/blob/929fd2a9da0d39b81c696ab6eeec6300a4600118/.meta/screenshots/intro.png)

</details>

</details>
 
# Licencia
<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Licencia Creative Commons" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a><br /><a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"></a>

/* b) Explorar la tabla "menu_items" para conocer los productos del menú.
	 1./ Realizar consultas para contestar las siguientes preguntas.*/
	-- ■ Encontrar el número de artículos en el menú.
		select Count(menu_item_id) as Num_Productos
		from menu_items;
		
	-- ■ ¿Cuál  es el artículo menos caro y el más caro en el menú?
		-- MAS CARO
		select item_name,price as Precio_max
		from menu_items
		where price=(select MAX(price) from menu_items);
		-- MENOS CARO
		select item_name,price as Precio_min
		from menu_items
		where price=(select MIN(price) from menu_items);
		
	-- ■ ¿Cuántos platos americanos hay el menú?
		select count(*) as Platos_americanos
		from menu_items
		where category= 'American';
		
	-- ■ ¿Cuál es el precio promedio de los platos?
		select ROUND(AVG(price),2) as precio_promedio
		from menu_items;
		
/* c) Explorar la tabla "order_details" para conocer los datos que han sido recolectados.
	 2.- Realizar consultas para contestar las siguientes preguntas: */ 
		
	-- ■ ¿Cuántos pedidos únicos se realizaron en total?
		select count(distinct order_id) as pedidos_unicos
		from order_details;
		
	-- ■ ¿Cuáles son los 5 pedidos que tuvieron el mayor número de artículos?
		select order_id , count(order_id) as Total_articulos
		from order_details
		group by order_id 
		Order by Total_articulos DESC
		limit 5;
		
	-- ■ ¿Cuándo se realizo el primer pedido y el último pedido?
		-- PRIMER PEDIDO
		select *
		from order_details
		order by order_date ASC,order_time ASC
		LIMIT 1;
		-- ULTIMO PEDIDO
		select *
		from order_details
		order by order_date DESC,order_time DESC
		LIMIT 1;
		
	-- ■ ¿Cuántos pedidos se hicieron entre el '2023-01-01' y el '2023-01-05'?
		select COUNT(order_details_id) as Total_pedidos
		from order_details
		where order_date between '2023-01-01' and '2023-01-05';
		
/* d) Usar ambas tablas para conocer la reacción de los clientes respecto al menú
	1.- realizar un left join entre order_details y menu_items con el identificador item_id(tabla order_details) 
	y menu_item_id (tabla menu_items). 
	Primero borramos las filas de order_details nulas para mejor union de tablas*/
	delete from order_details
	where item_id is null;
	-- UNION
	select order_details.order_details_id,order_details.order_id,order_details.order_date, order_details.order_time,order_details.item_id,
			menu_items.item_name,menu_items.category,menu_items.price
	from order_details
	LEFT JOIN menu_items ON order_details.item_id=menu_items.menu_item_id;
	
/* e) Una vez que hayas explorado los datos en las tablas correspondientes y respondido las
preguntas planteadas, realiza un análisis adicional utilizando este join entre las tablas. El
objetivo es identificar 5 puntos clave que puedan ser de utilidad para los dueños del
restaurante en el lanzamiento de su nuevo menú. Para ello, crea tus propias consultas y
utiliza los resultados obtenidos para llegar a estas conclusiones.*/

/* 1. INGRESOS TOTALES*/
	select sum(menu_items.price) as Ingreso_Total
	from order_details
	LEFT JOIN menu_items ON order_details.item_id=menu_items.menu_item_id;

	--Los ingresos generados durante 3 meses de ventas son de $159,217.90
	--INGRESOS MENSUALES
	Select mes, ingresos, 
	ROUND(((ingresos-LAG(ingresos) OVER (ORDER BY mes))/LAG(ingresos) OVER(ORDER BY mes))*100,2) as Porcentaje_crecimiento
	FROM(
	select extract(month FROM order_details.order_date) as mes,SUM(menu_items.price) as ingresos
	from order_details
	LEFT JOIN menu_items ON order_details.item_id=menu_items.menu_item_id
	Group by mes) AS ingresos_mensuales
	order by mes;
    /* Basandonos en los resultados obtenidos: durante el mes de enero-febrero se registro una
	baja en los ingresos de -5.62% respecto al mes anterior, sin embargo en el mes
	de febrero-marzo se logro revertir la baja y registrando un aumento en los ingresos de hasta 7.5% 
	respecto al mes anterior sugiriendo que se están tomando medidas efectivas y un aumento positivo en 
	la preferencia de los clientes, se recomienda mantener estas medidas para conservar dicha tendencia.*/ 
	
/* 2. INGRESOS POR CATEGORIA*/	
	select menu_items.category, SUM(menu_items.price) as Ingresos_categoria,
		ROUND(SUM(menu_items.price)/(select SUM(menu_items.price) 
		from order_details
		LEFT JOIN menu_items ON order_details.item_id=menu_items.menu_item_id)*100,2) as porcentaje
		from order_details
		LEFT JOIN menu_items ON order_details.item_id=menu_items.menu_item_id
		group by menu_items.category
		order by Ingresos_categoria DESC;
	/* El resultado obtenido es que la categoria de productos más demandada es la italiana
	con un total de ingresos igual a $49,462.70, seguido por la comida asiatica $46,720.65 
	representando un 31.07% y 29.34% respectivamente de los ingresos totales durante los meses enero-marzo. 
	Saber que categorías son las más rentables para el negocio es de vital importancia,
	implementando nuevos platillos de esas categorias, enfocar recursos y mejoras en estas areas ó 
	abrir algunas sucursales especificas */
	
/* 3. INGRESOS POR PRODUCTO*/
		select menu_items.item_name, SUM(menu_items.price) as Ingresos_producto,
		ROUND(SUM(menu_items.price)/(select SUM(menu_items.price) 
		from order_details
		LEFT JOIN menu_items ON order_details.item_id=menu_items.menu_item_id)*100,2) as porcentaje
		from order_details
		LEFT JOIN menu_items ON order_details.item_id=menu_items.menu_item_id
		group by menu_items.item_name
		order by Ingresos_producto DESC;
	
	 /* Los resultados nos arrojan que el producto más vendido es Korean Beef Bowl 
	 dandonos un ingreso total de $10,554.60 representando un 6.63% de los ingresos totales, seguido de Spaghetti 
	 Meatballs con un 5.30%. Conocer los intereses de los clientes es de utilidad para una mejor colocación en 
	 el mercado, priorizar los recursos a los productos más vendidos para mantener este nivel de ventas*/
	
/* 4. PRODUCTOS MAS VENDIDOS*/
	select menu_items.item_name, count(*) as Ventas
	from order_details
	LEFT JOIN menu_items ON order_details.item_id=menu_items.menu_item_id
	group by menu_items.item_name
	order by Ventas DESC
	Limit 3;
	
	/* Los productos más populares son Hamburger, Edamame y Korean Beef Bowl. 
	Conocer cuales son los productos más demandados entre los clientes permite priorizar los recursos
	y las inversiones del mes siguiente, de igual forma se da a conocer la relacion entre Ingresos-producto, 
	siendo Korean Beef Bowl quien genera mayor ingreso pero con menores ventas, concluyendo que requiere mayor 
	enfasis para una mejor popularidad persiviendo mayores ingresos a futuro*/

/* 5. PRODUCTO MENOS VENDIDO*/
	select menu_items.item_name, count(*) as Ventas
	from order_details
	LEFT JOIN menu_items ON order_details.item_id=menu_items.menu_item_id
	group by menu_items.item_name
	order by Ventas ASC
	Limit 3;
	/* Por otro lado, los productos menos populares son Chicken Tacos,Potstickers y Cheese Lasagna. 
	Con esta información podemos conocer cuales son los productos menos consumidos, teniendo asi 
	diversas alternativas asignarles mejor publicidad para darlos a conocer, eliminarlos del menú 
	o invertir lo menor posible y evitar posibles perdidas*/



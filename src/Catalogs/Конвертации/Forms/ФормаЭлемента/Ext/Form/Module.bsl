﻿
&НаСервере
Процедура КД3_ПриСозданииНаСервереПосле(Отказ, СтандартнаяОбработка)
	
	Обработчики = Новый Массив;
	Обработчики.Добавить("АлгоритмПередКонвертацией");
	Обработчики.Добавить("АлгоритмПередОтложеннымЗаполнением");
	Обработчики.Добавить("АлгоритмПослеКонвертации");
	
	КД3_Метаданные.ПриСозданииНаСервере(Обработчики, ЭтотОбъект, Объект, Отказ);
	ЭтотОбъект["КД3_Конфигурация"] = Объект.Конфигурация;
	
КонецПроцедуры

&НаКлиенте
Процедура КД3_ДокументСформирован(Элемент)
	ИмяОбработчика = Сред(Элемент.Имя, 5);
	КД3_МетаданныеКлиент.УстановитьТекст(ЭтотОбъект, Элемент.Имя, Объект[ИмяОбработчика]);
КонецПроцедуры

&НаКлиенте
Процедура КД3_ПриОткрытииПосле(Отказ)
	КД3_МетаданныеКлиент.ПриОткрытии(ЭтотОбъект, Объект);
КонецПроцедуры

&НаКлиенте
Процедура КД3_ПередЗаписьюПосле(Отказ, ПараметрыЗаписи)
	КД3_МетаданныеКлиент.ПередЗаписью(ЭтотОбъект, Объект, Отказ);
КонецПроцедуры

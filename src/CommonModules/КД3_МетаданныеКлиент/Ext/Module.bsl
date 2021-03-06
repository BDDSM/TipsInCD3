﻿
Процедура ПриОткрытии(Форма, Объект) Экспорт
	ИзвлечьИсходники(Форма, Объект);
	ПриИзмененииКонфигурации(Форма, Объект);
КонецПроцедуры

Процедура ПередЗаписью(Форма, Объект, Отказ) Экспорт
	
	Если Не Отказ Тогда
		Для Каждого ЭлементСписка Из Форма["КД3_Обработчики"] Цикл
			ИмяОбработчика = ЭлементСписка.Значение;
			ИмяРеквизита = "КД3_" + ИмяОбработчика;
			НовоеЗначение = КД3_МетаданныеКлиент.ПолучитьТекст(Форма, ИмяРеквизита);
			Если НовоеЗначение <> Объект[ИмяОбработчика] Тогда
				Объект[ИмяОбработчика] = НовоеЗначение;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

Процедура ПриИзмененииКонфигурации(Форма, Объект) Экспорт
	
	Конфигурация = Форма["КД3_Конфигурация"];
	
	КаталогИсходников = КД3_Кэш()["КаталогИсходников"];
	КаталогМетаданных = КД3_Кэш()[Конфигурация];
	Если КаталогМетаданных = Неопределено Тогда
		
		// Распаковка файлов общих для конфигурации
		КаталогМетаданных = КаталогИсходников + Строка(Конфигурация.УникальныйИдентификатор()) + "\";
		ФайлМакета = КаталогИсходников + "bsl_console.zip";
		ZipФайл = Новый ЧтениеZipФайла(ФайлМакета);
		ZipФайл.Извлечь(ZipФайл.Элементы.Найти("bslMetadata.json"), КаталогМетаданных);
		КопироватьФайл(КаталогМетаданных + "bslMetadata.json", КаталогМетаданных + "bslMetadata_oringin.json");
		ЗаполнитьКоллекциюМетаданных(Конфигурация, КаталогМетаданных);
		
		КД3_Кэш()[Конфигурация] = КаталогМетаданных;
	КонецЕсли;
	
	// Создание экземпляра для каждого обработчика
	Для Каждого ЭлементСписка Из Форма["КД3_Обработчики"] Цикл
		ИмяОбработчика = ЭлементСписка.Значение;
		ИмяРеквизита = "КД3_" + ИмяОбработчика;
		
		КаталогОбработчика = КаталогМетаданных + ИмяОбработчика + "\";
		Если Форма[ИмяРеквизита] <> КаталогОбработчика + "index.html" Тогда
			ТестФайл = Новый Файл(КаталогОбработчика);
			Если НЕ ТестФайл.Существует() Тогда
				ZipФайл.ИзвлечьВсе(КаталогОбработчика);
				// Замена общих метаданных на метаданные конфигурации
				КопироватьФайл(КаталогМетаданных + "bslMetadata.json", КаталогОбработчика + "bslMetadata.json");
			КонецЕсли;
			
			Если НЕ ПустаяСтрока(Форма[ИмяРеквизита]) Тогда
				НовоеЗначение = КД3_МетаданныеКлиент.ПолучитьТекст(Форма, ИмяРеквизита);
				Если НовоеЗначение <> Объект[ИмяОбработчика] Тогда
					Объект[ИмяОбработчика] = НовоеЗначение;
				КонецЕсли;
			КонецЕсли;
			Форма[ИмяРеквизита] = КаталогОбработчика + "index.html";
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

Процедура ИзвлечьИсходники(Форма, Объект)
	
	КаталогИсходников = КД3_Кэш()["КаталогИсходников"];
	Если КаталогИсходников = Неопределено Тогда
		КаталогВременныхФайлов = КаталогВременныхФайлов();
		КаталогИсходников = КаталогВременныхФайлов + "bsl_console\";
		ТестФайл = Новый Файл(КаталогИсходников);
		Если НЕ ТестФайл.Существует() Тогда
			СоздатьКаталог(КаталогИсходников);
		КонецЕсли;
		
		// Получение файла макета общего для всех конфигураций
		ФайлМакета = КаталогИсходников + "bsl_console.zip";
		ТестФайл = Новый Файл(ФайлМакета);
		Если НЕ ТестФайл.Существует() Тогда
			ДанныеМакета = ПолучитьИзВременногоХранилища(КД3_Метаданные.ПолучитьФайлМакетаИсходников());
			ДанныеМакета.Записать(ФайлМакета);
		КонецЕсли;
		КД3_Кэш()["КаталогИсходников"] = КаталогИсходников;
	КонецЕсли;
	
КонецПроцедуры

Процедура ЗаполнитьКоллекциюМетаданных(Конфигурация, КаталогМетаданных)
	
	ИмяФайла = КаталогМетаданных + "bslMetadata_oringin.json";
	
	Файл = Новый ЧтениеJSON();
	Файл.ОткрытьФайл(ИмяФайла);
	
	ДанныеПрочитаны = Ложь;
	
	Попытка
		bslmetadata = ПрочитатьJSON(Файл);
		Адрес = ПоместитьВоВременноеХранилище(bslmetadata);
		КД3_Метаданные.ЗаполнитьКоллекциюМетаданных(Адрес, Конфигурация);
		bslmetadata = ПолучитьИзВременногоХранилища(Адрес);
		ДанныеПрочитаны = Истина;
	Исключение
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не удалось заполнить коллекцию метаданных:" + Символы.ПС + ОписаниеОшибки());
		Возврат;
	КонецПопытки;
	
	Файл.Закрыть();
	
	Если ДанныеПрочитаны Тогда
	
		Файл = Новый ЗаписьJSON();
		Файл.ОткрытьФайл(КаталогМетаданных + "bslMetadata.json");
		Попытка
			ЗаписатьJSON(Файл, bslmetadata);
		Исключение
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не удалось сохранить коллекцию метаданных:" + Символы.ПС + ОписаниеОшибки());
			ДанныеПрочитаны = Ложь;
		КонецПопытки;
		
		Файл.Закрыть();
		
	КонецЕсли;
	
КонецПроцедуры

Функция View(Форма, ИмяРеквизита)
	Возврат Форма.Элементы[ИмяРеквизита].Документ.defaultView
КонецФункции

Процедура УстановитьТекст(Форма, ИмяРеквизита, Текст, Позиция = Неопределено) Экспорт
	
	View(Форма, ИмяРеквизита).setText(Текст, Позиция);
	
КонецПроцедуры

Функция ПолучитьТекст(Форма, ИмяРеквизита) Экспорт
	
	Возврат View(Форма, ИмяРеквизита).getText();
	
КонецФункции

Функция ОчиститьТекст(Форма, ИмяРеквизита) Экспорт
	
	Возврат View(Форма, ИмяРеквизита).eraseText();
	
КонецФункции

import { Plugins } from '@capacitor/core';
import { IDatePicker, DatePickerOptions } from './definitions';

const {DatePickerPlugin} = Plugins;

export class DatePicker implements IDatePicker {
    show(options: DatePickerOptions): Promise<{ value: string }> {
        return DatePickerPlugin.show(options);
    }
}

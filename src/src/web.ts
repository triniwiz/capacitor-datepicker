import { WebPlugin } from '@capacitor/core';
import { IDatePicker, DatePickerOptions } from './definitions';

export class DatePickerPluginWeb extends WebPlugin implements IDatePicker {
    constructor() {
        super({
            name: 'DatePickerPlugin',
            platforms: ['web']
        });
    }

    async show(options: DatePickerOptions): Promise<{ value: string }> {
        console.log('ECHO', options);
        return Promise.resolve({value: ''});
    }
}

const DatePickerPlugin = new DatePickerPluginWeb();

export { DatePickerPlugin };

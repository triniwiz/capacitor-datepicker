declare global {
  interface PluginRegistry {
    DatePickerPlugin?: IDatePicker;
  }
}

export interface DatePickerOptions {
  mode: 'date' | 'time';
  is24Hours?: false;
  date: string;
  theme?: string;
  cancelText?:string;
  okText?:string;
  cancelButtonColor?:string;
  okButtonColor?:string;
}

export interface IDatePicker {
  show(options: DatePickerOptions): Promise<{ value: string }>;
}

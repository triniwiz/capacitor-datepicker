declare global {
  interface PluginRegistry {
    DatePickerPlugin?: IDatePicker;
  }
}

export interface DatePickerOptions {
  mode: 'date' | 'time';
  date: string;
  is24Hours?: false;
  theme?: string;
  cancelText?: string;
  okText?: string;
  cancelButtonColor?: string;
  okButtonColor?: string;
  titleTextColor?: string;
  titleBgColor?: string;
}

export interface IDatePicker {
  show(options: DatePickerOptions): Promise<{ value: string }>;
}

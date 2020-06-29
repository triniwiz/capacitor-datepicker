declare global {
    interface PluginRegistry {
        DatePickerPlugin?: IDatePicker;
    }
}

export interface DatePickerOptions {
    mode: 'date' | 'time';
    title: string;
    date: string;
    is24Hours?: boolean;
    theme?: string;
    cancelText?: string;
    okText?: string;
    /**
     * Sets the color of the negative or cancel button of the picker dialogs
     * Works for both android and iOS. Should be a hexcode, but can be a color name as well.
     */
    cancelButtonColor?: string;
    /**
     * Sets the color of the positive or confirm button of the picker dialogs
     * Works for both android and iOS. Should be a hexcode, but can be a color name as well.
     */
    okButtonColor?: string;
    /**
     * Sets the color of the title text in the header if present
     * Works only on iOS. Should be a hexcode, but can be a color name as well.
     */
    titleTextColor?: string;
    /**
     * Sets the color of the background of the title bar
     * Works only on iOS. Should be a hexcode, but can be a color name as well.
     */
    titleBgColor?: string;
}

export interface IDatePicker {
    show(options: DatePickerOptions): Promise<{ value: string }>;
}

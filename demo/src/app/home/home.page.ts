import { Component } from '@angular/core';
import { DatePicker } from 'capacitor-datepicker';
@Component({
  selector: 'app-home',
  templateUrl: 'home.page.html',
  styleUrls: ['home.page.scss']
})
export class HomePage {
  picker: DatePicker;
  selectedDate: string;
  selectedTime: string;
  constructor() {
    this.picker = new DatePicker();
  }

  async showDate() {
    const response = await this.picker.show({
      mode: 'date',
      date: new Date().toISOString(),
      theme: 'AppDialogTheme',
      cancelButtonColor: 'red',
      okButtonColor: 'yellow'
    });
    this.selectedDate = response.value;
  }

  async showTime() {
    const response = await this.picker.show({
      mode: 'time',
      date: new Date().toISOString()
    });
    this.selectedTime = response.value;
  }
}

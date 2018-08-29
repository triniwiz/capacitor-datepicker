package co.fitcom.capacitor.datepicker;


import android.app.DatePickerDialog;

import android.app.Dialog;
import android.app.TimePickerDialog;

import android.content.DialogInterface;
import android.graphics.Color;
import android.support.annotation.Nullable;
import android.view.View;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.TimePicker;

import com.getcapacitor.JSObject;
import com.getcapacitor.NativePlugin;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.TimeZone;

import co.fitcom.capacitor.datepicker.capacitordatepicker.R;

@NativePlugin()
public class DatePickerPlugin extends Plugin {

    private String toISO8601UTC(Date date) {
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX");
        TimeZone tz = TimeZone.getTimeZone("UTC");
        dateFormat.setTimeZone(tz);

        return dateFormat.format(date);
    }

    private Date fromISO8601UTC(String date) throws ParseException {
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX");
        TimeZone tz = TimeZone.getTimeZone("UTC");
        dateFormat.setTimeZone(tz);
        return dateFormat.parse(date);
    }

    private int getTheme(@Nullable String theme) {
        return theme != null ? getContext().getResources().getIdentifier(theme, "style", getContext().getPackageName()) : R.style.DialogTheme;
    }

    @PluginMethod()
    public void show(final PluginCall call) {
        String mode = call.getString("mode");
        String date = call.getString("date");
        String max = call.getString("max");
        String min = call.getString("min");
        final String cancelText = call.getString("cancelText", "Cancel");
        final String okText = call.getString("okText", "Ok");
        boolean is24Hours = call.getBoolean("is24Hours", false);
        String theme = call.getString("theme");
        String title = call.getString("title");
        String okButtonColor = call.getString("okButtonColor");
        final String cancelButtonColor = call.getString("cancelButtonColor");
        final JSObject res = new JSObject();
        try {
            Date javaData = fromISO8601UTC(date);
            final Calendar calendar = Calendar.getInstance();
            calendar.setTime(javaData);
            if (mode.equals("time")) {

                TimePickerDialog timePickerDialog = new TimePickerDialog(getContext(), getTheme(theme), new TimePickerDialog.OnTimeSetListener() {
                    @Override
                    public void onTimeSet(TimePicker view, int hourOfDay, int minute) {
                        Calendar calendar1 = Calendar.getInstance();
                        calendar1.setTime(new Date());
                        calendar1.set(calendar.get(Calendar.YEAR), calendar.get(Calendar.MONTH), calendar.get(Calendar.DAY_OF_MONTH), hourOfDay, minute);
                        res.put("value", toISO8601UTC(calendar1.getTime()));
                        call.resolve(res);
                    }
                }, calendar.get(Calendar.HOUR), calendar.get(Calendar.MINUTE), is24Hours);

                if (title != null) {
                    timePickerDialog.setTitle(title);
                }

                timePickerDialog.create();

                Button okButton = timePickerDialog.getButton(Dialog.BUTTON_POSITIVE);

                if (okText != null) {
                    okButton.setText(okText);
                }

                if (okButtonColor != null) {
                    okButton.setTextColor(Color.parseColor(okButtonColor));
                }

                Button cancelButton = timePickerDialog.getButton(Dialog.BUTTON_NEGATIVE);

                cancelButton.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        res.put("value", null);
                        call.resolve(res);
                    }
                });

                if (cancelText != null) {
                    cancelButton.setText(cancelText);
                }


                if (cancelButtonColor != null) {
                    cancelButton.setTextColor(Color.parseColor(cancelButtonColor));
                }

                timePickerDialog.show();

            } else {
                final DatePickerDialog datePickerDialog = new
                        DatePickerDialog(getContext(), getTheme(theme), new DatePickerDialog.OnDateSetListener() {
                    @Override
                    public void onDateSet(DatePicker view, int year, int month, int dayOfMonth) {
                        Calendar calendar1 = Calendar.getInstance();
                        calendar1.setTime(new Date());
                        calendar1.set(year, month, dayOfMonth);
                        res.put("value", toISO8601UTC(calendar1.getTime()));
                        call.resolve(res);
                    }
                }, calendar.get(Calendar.YEAR), calendar.get(Calendar.MONTH), calendar.get(Calendar.DAY_OF_MONTH));


                if (title != null) {
                    datePickerDialog.setTitle(title);
                }

                datePickerDialog.create();
                DatePicker picker = datePickerDialog.getDatePicker();

                if (max != null) {
                    Date maxDate = fromISO8601UTC(max);
                    picker.setMaxDate(maxDate.getTime());
                }

                if (min != null) {
                    Date mixDate = fromISO8601UTC(min);
                    picker.setMaxDate(mixDate.getTime());
                }


                Button okButton = datePickerDialog.getButton(Dialog.BUTTON_POSITIVE);
                if (okText != null) {
                    okButton.setText(okText);
                }

                if (okButtonColor != null) {
                    okButton.setTextColor(Color.parseColor(okButtonColor));
                }

                Button cancelButton = datePickerDialog.getButton(Dialog.BUTTON_NEGATIVE);

                cancelButton.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        res.put("value", null);
                        call.resolve(res);
                    }
                });

                if (cancelText != null) {
                    cancelButton.setText(cancelText);
                }

                if (cancelButtonColor != null) {
                    cancelButton.setTextColor(Color.parseColor(cancelButtonColor));
                }

                datePickerDialog.show();
            }
        } catch (ParseException e) {
            call.reject(e.getMessage(), e);
        }

    }
}

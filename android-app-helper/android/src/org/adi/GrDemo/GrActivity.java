/*
 * Copyright (c) 2021 Analog Devices Inc.
 *
 * This file is part of Scopy
 * (see http://www.github.com/analogdevicesinc/scopy).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

package org.adi.GrDemo;

import java.io.File;
import java.io.IOException;
import org.qtproject.qt5.android.bindings.QtActivity;
import android.content.pm.PackageManager;
import android.content.Intent;
import android.content.Context;
import android.content.ComponentName;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.view.WindowManager;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.NotificationChannel;
import android.app.PendingIntent;

import android.widget.RemoteViews;
import android.widget.Toast;

import android.os.PowerManager;
import android.os.PowerManager.WakeLock;


//import androidx.core.app.NotificationCompat;


public class GrActivity extends QtActivity
{
	
	boolean initialized;

	@Override
	public void onCreate(Bundle savedInstanceState)
	{
		System.out.println("-- GrActivity: onCreate");
		initialized = false;
		super.onCreate(savedInstanceState);
		

	}

	@Override
	protected void onStart()
	{
		System.out.println("-- GrActivity: onStart");
		super.onStart();
		if(initialized) {
			;
		}
	}

	@Override
	protected void onStop()
	{
		System.out.println("-- GrActivity: onStop");
		if (initialized) {
		;	
		}
		super.onStop();
	}

        @Override
	protected void onResume()
	{		
		super.onResume();
	}

	protected void onPause(){
		System.out.println("-- GrActivity: onPause - saving application state to ini file ");
		if (initialized) {
			;
		}

		super.onPause();
	}

	protected void onDestroy(){
		System.out.println("-- GrActivity: onDestroy ");		
		if(initialized) {
			;
		}

		super.onDestroy();
	}	
}

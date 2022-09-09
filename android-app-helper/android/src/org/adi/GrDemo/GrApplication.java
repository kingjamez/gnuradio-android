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

import org.qtproject.qt5.android.bindings.QtApplication;


import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.lang.Object;
import java.lang.System;

import android.system.Os;
import android.system.ErrnoException;

import android.app.Application;
import android.content.Context;
import android.os.Environment;
import android.content.res.AssetManager;
import android.preference.PreferenceManager;


public class GrApplication extends QtApplication
{
	@Override
	public void onCreate()
	{
		System.out.println("QtApplication started");
		String apk = getApplicationInfo().sourceDir;
		String cache = getApplicationContext().getCacheDir().toString();
		System.out.println("sourcedir: "+ getApplicationInfo().sourceDir);
		System.out.println("public sourcedir: "+ getApplicationInfo().publicSourceDir);
		String libdir = getApplicationInfo().nativeLibraryDir;		
		System.out.println("native library dir:" + libdir);
		System.out.println("applcation cache dir:" + cache);
		System.out.println("datadir"+getApplicationInfo().dataDir);
		System.out.println("protecteddatadir"+getApplicationInfo().deviceProtectedDataDir);
		System.out.println("Hello GrApplication !");

		try {
		    Os.setenv("APPDATA", cache, true);
		    Os.setenv("PYFILE", apk + "/assets/untitled.py",true);
		    Os.setenv("LD_LIBRARY_PATH", libdir, true);

		}

		catch(ErrnoException x) {
		     System.out.println("Cannot set envvars");
		}

		super.onCreate();
	}

}

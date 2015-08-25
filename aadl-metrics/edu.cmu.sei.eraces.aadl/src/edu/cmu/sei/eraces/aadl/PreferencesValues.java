/*
 * Copyright (c) 2015 Carnegie Mellon University.
 * All Rights Reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS," WITH NO WARRANTIES WHATSOEVER. CARNEGIE 
 * MELLON UNIVERSITY EXPRESSLY DISCLAIMS TO THE FULLEST EXTENT PERMITTEDBY 
 * LAW ALL EXPRESS, IMPLIED, AND STATUTORY WARRANTIES, INCLUDING, WITHOUT 
 * LIMITATION, THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, 
 * AND NON-INFRINGEMENT OF PROPRIETARY RIGHTS.
 *
 * This Program is distributed under a BSD license.  Please see LICENSE.TXT file
 * or permission@sei.cmu.edu for more information.  
 * DM-0002674
 */

package edu.cmu.sei.eraces.aadl;

import org.eclipse.jface.preference.IPreferenceStore;

/**
 * Accessors for preference value
 * @author hugues
 *
 */
public class PreferencesValues {

	public static boolean getPrefGlobVar() {
		IPreferenceStore store = Activator.getDefault().getPreferenceStore();
		return (store.getBoolean(PreferenceConstants.ERACES_PREF_GLOBVAR));
	}

	public static boolean getPrefSubprogram() {
		IPreferenceStore store = Activator.getDefault().getPreferenceStore();
		return (store.getBoolean(PreferenceConstants.ERACES_PREF_GLOBVAR));
	}

}

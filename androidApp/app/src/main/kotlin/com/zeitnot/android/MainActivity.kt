package com.zeitnot.android

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import com.zeitnot.android.coreui.ColorPalette
import com.zeitnot.android.coreui.Spacing
import com.zeitnot.android.coreui.Typography

class MainActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        SharedLibrary.load()

        setContent {
            SharedLibraryStatus()
        }
    }

}

@Composable
private fun SharedLibraryStatus() {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(ColorPalette.background)
            .padding(Spacing.large),
        contentAlignment = Alignment.Center) {
        BasicText(
            text = stringResource(R.string.shared_library_loaded),
            style = Typography.label)
    }
}

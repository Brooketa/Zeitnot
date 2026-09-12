package com.zeitnot.android.setup.components

import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.zeitnot.android.coreui.Typography

@Composable
fun SectionHeader(title: String, modifier: Modifier = Modifier) {
    BasicText(text = title.uppercase(), style = Typography.label, modifier = modifier)
}

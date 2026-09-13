package com.zeitnot.android.setup.components

import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import com.zeitnot.android.R
import com.zeitnot.android.coreui.Spacing
import com.zeitnot.android.coreui.Typography

@Composable
fun RulesetCell(model: RulesetCellModel, onSelect: () -> Unit, modifier: Modifier = Modifier) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = null,
                onClick = onSelect)
            .padding(Spacing.large),
        horizontalArrangement = Arrangement.spacedBy(Spacing.large),
        verticalAlignment = Alignment.CenterVertically) {
        Column(
            modifier = Modifier.weight(1f),
            verticalArrangement = Arrangement.spacedBy(Spacing.extraSmall)) {
            BasicText(text = model.category.uppercase(), style = Typography.micro)

            BasicText(
                text = stringResource(
                    R.string.time_control_notation,
                    model.baseMinutes,
                    model.incrementSeconds),
                style = Typography.title)

            BasicText(text = model.description, style = Typography.callout)
        }

        SelectionIndicator(isSelected = model.isSelected)
    }
}

data class RulesetCellModel(
    val id: String,
    val category: String,
    val description: String,
    val baseMinutes: Int,
    val incrementSeconds: Int,
    val isSelected: Boolean
)

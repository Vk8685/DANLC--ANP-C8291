import pandas as pd
import streamlit as st
import plotly.express as px

# Set the layout for the Streamlit page
st.set_page_config(layout="wide")

# Load the dataset (adjust the file path as needed)
df = pd.read_csv("data.csv")

# List of important columns based on the dataset provided
necessary_columns = [
    'State', 'District', 'Population', 'Male', 'Female',
    'Literate', 'Female_Literate', 'Male_Literate', 
    'Latitude', 'Longitude', 'Total_Power_Parity', 
    'Power_Parity_Above_Rs_545000', 'Power_Parity_Rs_90000_150000'
]

# Filter the dataset for necessary columns
df = df[necessary_columns]

# Add calculated columns
df['Sex Ratio'] = (df['Female'] / df['Male']) * 1000  # Sex ratio calculation
df['Literacy Rate'] = (df['Literate'] / df['Population']) * 100  # Overall literacy rate
df['Female Literacy Rate'] = (df['Female_Literate'] / df['Female']) * 100  # Female literacy rate
df['Male Literacy Rate'] = (df['Male_Literate'] / df['Male']) * 100  # Male literacy rate

# List of states for selection
list_of_state = list(df["State"].unique())
list_of_state.insert(0, "Overall India")  # Start with "Overall India"

# Sidebar title and user inputs
st.sidebar.title("India Data Visualization")
selected_state = st.sidebar.selectbox("Select a state", list_of_state)

# Select primary and secondary parameters from the necessary columns and calculated columns
primary_options = [
    'Population', 'Sex Ratio', 'Literacy Rate', 'Female Literacy Rate', 
    'Male Literacy Rate', 'Total_Power_Parity', 'Latitude', 'Longitude',
    'Power_Parity_Above_Rs_545000', 'Power_Parity_Rs_90000_150000'
]

# Initial chart type options based on selected state
if selected_state == "Overall India":
    chart_options = ["Select Chart", "Bar Chart", "Line Chart", "Pie Chart", "Histogram", "Mapbox"]
else:
    chart_options = ["Select Chart", "Bar Chart", "Line Chart", "Pie Chart", "Histogram", "Mapbox"]

primary = st.sidebar.selectbox("Select Primary Parameter", primary_options)
secondary = st.sidebar.selectbox("Select Secondary Parameter", primary_options)
chart_type = st.sidebar.selectbox("Select Chart Type", chart_options)

# Display a big title and introductory text if no state is selected
if selected_state == "Overall India" and chart_type == "Select Chart":
    st.markdown("<h1 style='text-align: center; color: black;'>India Data Visualization</h1>", unsafe_allow_html=True)
    st.markdown("<h3 style='text-align: center; color: gray;'>Welcome to the India Data Visualization Dashboard!</h3>", unsafe_allow_html=True)
    st.markdown("<p style='text-align: center;'>Please select a state and chart type from the sidebar to begin exploring the data.</p>", unsafe_allow_html=True)

else:
    # Plot button to trigger visualization
    plot_button = st.sidebar.button("Plot")  # Add the plot button in the sidebar

    if plot_button:
        # Filter data based on user selection
        if selected_state == "Overall India":
            # Create a summary DataFrame for each state
            df_map = df.groupby('State').agg({
                'Population': 'sum',
                'Male': 'sum',
                'Female': 'sum',
                'Sex Ratio': lambda x: (x.sum() / df.loc[df['State'] == x.name, 'Male'].sum()) * 1000,
                'Latitude': 'mean',
                'Longitude': 'mean'
            }).reset_index()
            df_map['Sex Ratio'] = (df_map['Female'] / df_map['Male']) * 1000

        else:
            # Filter data for the selected state
            df_state = df[df["State"] == selected_state]
            df_map = df_state.dropna(subset=["Latitude", "Longitude"])  # Ensure no NaN values in lat/lon

        # Visualization based on user selection
        if chart_type == "Bar Chart":
            # Create a grouped bar plot for the selected state
            fig = px.bar(df_state, x="District", y=[primary, secondary], barmode="group",
                         title=f"Comparison of {primary} and {secondary} in {selected_state}",
                         labels={primary: primary, secondary: secondary})
            # Display the bar chart
            st.plotly_chart(fig, use_container_width=True)
            st.write(f"**Note:** This bar chart compares the **{primary}** and **{secondary}** values for the selected state.")

        elif chart_type == "Line Chart":
            # Create a line plot for selected state or Overall India
            fig = px.line(df_state, x="District", y=[primary, secondary], title=f"Trend of {primary} and {secondary} in {selected_state}",
                          labels={primary: primary, secondary: secondary})

            # Display the line chart
            st.plotly_chart(fig, use_container_width=True)
            st.write(f"**Note:** This line chart shows the trend of **{primary}** and **{secondary}** over districts in {selected_state}.")

        elif chart_type == "Pie Chart":
            # Create a pie chart for the primary parameter
            fig = px.pie(df_state, values=primary, names="District", title=f"{primary} Distribution in {selected_state}")

            # Display the pie chart
            st.plotly_chart(fig, use_container_width=True)
            st.write(f"**Note:** This pie chart illustrates the distribution of **{primary}** across districts in {selected_state}.")

        elif chart_type == "Histogram":
            # Create a histogram for the primary parameter
            fig = px.histogram(df_state, x=primary, title=f"Histogram of {primary} in {selected_state}",
                               labels={primary: primary})

            # Display the histogram
            st.plotly_chart(fig, use_container_width=True)
            st.write(f"**Note:** This histogram represents the distribution of **{primary}** values in {selected_state}.")

        elif chart_type == "Mapbox":
            # Check for Latitude and Longitude columns before plotting
            if 'Latitude' in df.columns and 'Longitude' in df.columns:
                # Update note to clarify the visualization
                st.write(f"**Note:** In this Mapbox visualization, the size of each point represents **{primary}** while the color represents **{secondary}**. The **Sex Ratio** is calculated as the number of females per 1000 males. Hover over the points to see district names.")

                # Create a Mapbox plot using latitude and longitude
                fig = px.scatter_mapbox(
                    df_map,
                    lat="Latitude", 
                    lon="Longitude", 
                    size=primary,  # Use primary for sizing
                    color=secondary,  # Use secondary for color
                    hover_name="State",  # Show state name on hover
                    title=f"Mapbox Visualization of {primary} and {secondary} in Overall India",
                    mapbox_style="open-street-map", 
                    zoom=4,  # Adjust zoom level as necessary for the states
                    center={"lat": df_map["Latitude"].mean(), "lon": df_map["Longitude"].mean()}  # Center on the average latitude and longitude
                )
                # Display the Mapbox chart
                st.plotly_chart(fig, use_container_width=True)

                # Additional note for size representation
                st.markdown(f"**The size of the points represents the value of {primary}, while the color represents the value of {secondary}.**")
            else:
                st.warning("Latitude and Longitude columns are missing from the dataset.")

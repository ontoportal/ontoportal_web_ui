const loaderHtml = `
  <div class="my-auto mx-auto">
    <div class="p-3">
      <div class="d-flex align-items-center flex-column">
        <div class="spinner-border">
          <div class="spinner-text my-2">Loading</div>
        </div>
      </div>
    </div>
  </div>
`;

export const showLoader = (element) => {
  element.innerHTML = loaderHtml;
}


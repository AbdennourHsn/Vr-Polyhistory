using UnityEngine;
using UnityEngine.UI;
public class InfoBubble : MonoBehaviour
{
    public Text infoBubble;
    void Update()
    {
        infoBubble.transform.position = this.transform.position;
        infoBubble.transform.rotation = Quaternion.LookRotation(infoBubble.transform.position - Camera.main.transform.position);
    }
}
